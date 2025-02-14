locals {
  # Construct the maps that contain the locations of the SSMP locations
  ssmpSecureLocs = zipmap(
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpSecureLocs.zipmapKeys,
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpSecureLocs.zipmapValues
  )
  ssmpConfLocs = zipmap(
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpConfLocs.zipmapKeys,
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpConfLocs.zipmapValues
  )
  env_name              = var.commonTags.oEnvironment
  db_role_sitecoremongo = "sitecoreMongo"
}