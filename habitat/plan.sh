pkg_name=sample-node-app
pkg_origin=nrycar
pkg_scaffolding="core/scaffolding-node"
pkg_version="3.0.1"
pkg_deps=(nrycar/libhelloworld)

pkg_exports=(
  [port]=app.port
)
pkg_exposes=(port)

declare -A scaffolding_env

# Define path to config file
scaffolding_env[APP_CONFIG]="{{pkg.svc_config_path}}/config.json"

do_install() {
  do_default_install
}
