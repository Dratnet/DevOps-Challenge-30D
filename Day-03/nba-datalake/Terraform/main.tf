module "nba-datalake" {
  source = "../../nba-datalake/"
  NBA_API_KEY = var.NBA_API_KEY
  NBA_ENDPOINT_URL = var.NBA_ENDPOINT_URL
}
