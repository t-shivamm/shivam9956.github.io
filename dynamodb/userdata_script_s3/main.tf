resource "aws_s3_bucket_object" "object" {
  bucket  = var.s3_bucket_name
  key     = "/tf_managed_userdata/${var.s3_script_alias}.userdata"
  content = data.template_file.wrapper.rendered
  etag    = md5(data.template_file.wrapper.rendered)
}

# resource "local_file" "temp_rendered_userdata" {
#     content  = data.template_file.wrapper.rendered
#     filename = local.temp_rendered_userdata_filepath
# }

data "template_file" "wrapper" {
  template = file("${path.module}/../../resources/scripts/userdata-v2/wrapper/${var.wrapper_script_name}")
  vars     = merge(var.wrapper_script_vars, { roleScriptText = data.template_file.role.rendered })
}

# Parameters will have to be passed via the script's normal mechanism e.g. Powershell uses param()
data "template_file" "role" {
  template = file("${path.module}/../../resources/scripts/userdata-v2/role/${var.role_script_name}")
}
