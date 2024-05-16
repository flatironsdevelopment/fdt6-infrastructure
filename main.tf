module "github_repo" {
  source                = "../../modules/github-repo"
  github_token          = var.github_token
  github_organization = var.github_organization
  project_name = var.project_name
}

module "github_actions" {
  source                = "../../modules/github-actions"
  github_token          = var.github_token
  project_name          = local.credentials.name
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region            = var.aws_region
  github_organization = var.github_organization
  kubernetes = true
  github_repo_name = module.github_repo.github_monorepo_name
  github_infrastructure_full_name = module.github_repo.github_infrastructure_full_name
  apps = toset(local.app_list)
  workers = toset(local.worker_list)
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "redis" {
  for_each = { for app in local.app_list : app.app_name => app if app.redis }
  source        = "../../modules/redis"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnets
  app_name  = each.value.app_name
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  cluster_name = var.project_name
}

module "cloud-watch" {
  source            = "../../modules/cloud-watch"
  project_name      = var.project_name
  slack_webhook_url = local.credentials.slack_webhook_url
}

module "s3" {
  source       = "../../modules/simple-storage-service"
  project_name = var.project_name
}

module "ecr" {
  source       = "../../modules/elastic-container-registry"
  project_name = var.project_name
}

module "database" {
  for_each = { for app in local.app_list : app.app_name => app if app.postgres }
  source                     = "../../modules/relational-database-service"
  app_name                   = each.value.app_name
  allowed_ip_list            = var.access_ip_range
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnets
  vpc_security_group_default = module.vpc.default_security_group_id
  db_username                = var.db_username
  db_password                = var.db_password
  db_name                = var.db_name
}

module "cognito" {
  for_each = { for app in local.app_list : app.app_name => app if app.cognito }
  source = "../../modules/cognito"

  app_name              = each.value.app_name
  application_url       = "https://${each.value.domain}"
  aws_region            = var.aws_region
  cognito_apikey_header = local.credentials.cognito_apikey_header
}

module "kubernetes" {
  source       = "../../modules/kubernetes"
  cluster_name = var.project_name
  iam_policies = {
    "alb"        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}AWSLoadBalancerControllerIAMPolicy",
    "cloudwatch" = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  }
  access_ip_range                   = local.credentials.access_ip_range
  default_security_group_id         = module.vpc.default_security_group_id
  cluster_primary_security_group_id = module.kubernetes.cluster_primary_security_group_id
  vpc_id                            = module.vpc.vpc_id
  private_subnets                   = module.vpc.private_subnets
  aws_region                        = var.aws_region
  project_name                      = var.project_name
}

module "secret-operator" {
  source       = "../../modules/secret-operator"
  aws_region   = var.aws_region
  provider_url = replace(module.kubernetes.cluster_oidc_issuer_url, "https://", "")
  project_name = var.project_name
  depends_on   = [module.kubernetes]
}

module "pod-reloader" {
  source      = "../../modules/pod-reloader"
  project_name = var.project_name
  depends_on = [
    module.kubernetes,
    module.argocd
  ]
}

module "ingress-controller" {
  source       = "../../modules/ingress-controller"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.project_name
  aws_region   = var.aws_region

  depends_on = [
    module.kubernetes,
    module.vpc
  ]
}

module "ingress-application" {
  source                    = "../../modules/ingress-application"
  vpc_id                    = module.vpc.vpc_id
  ssl                       = local.credentials.ssl
  ingress_group_name        = var.ingress_group_name
  default_security_group_id = module.vpc.default_security_group_id
  public_subnets            = module.vpc.public_subnets
  project_name = var.project_name
  apps = toset(local.app_list)

  depends_on = [
    module.kubernetes,
    module.vpc,
    module.namespaces
  ]
}

module "monitoring" {
  source = "../../modules/monitoring"

  ingress_ssl_arn       = local.credentials.ssl
  ingress_group_name    = var.ingress_group_name
  grafana_hostname      = local.credentials.grafana_domain
  grafana_admin_password = local.credentials.grafana_admin_password
  provider_url          = replace(module.kubernetes.cluster_oidc_issuer_url, "https://", "")
  project_name          = var.project_name
  cluster_name          = var.project_name
  aws_region            = var.aws_region
}

module "namespaces" {
  source = "../../modules/namespaces"
  namespace_name = "apps"

  depends_on = [
    module.kubernetes
  ]
}

module "argocd" {
  source               = "../../modules/argocd"
  argocd_host          = local.credentials.argo_domain
  slack_namespace      = "null"
  ingress_group_name   = var.ingress_group_name
  repo_helmcharts_url  = module.github_repo.github_repo_url
  slack_token          = "null"
  repo_helmcharts_name = "helmcharts"
  argo_admin_password  = bcrypt("${local.credentials.argo_admin_password}")
  ssl                  = local.credentials.ssl
  public_subnets       = module.vpc.public_subnets
  apps_types           = ["frontend", "backend"]
  project_name         = var.project_name
  github_token         = var.github_token
  github_username      = var.github_username
  namespace_name = "apps"

  depends_on = [
    module.ingress-controller,
    module.vpc,
    module.namespaces
  ]
}

