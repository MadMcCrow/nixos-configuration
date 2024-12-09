# support logging-in with authelia
{ lib, config, ... }:
let
  # shortcuts
  inherit (config.nixos) web;
  inherit (web.auth) authelia;
in
{
  config = lib.mkIf authelia.enable {
    services.nextcloud.settings = {
      "$CONFIG" = {
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        oidc_login_provider_url = "${authelia.subDomain}.${domain}";
        oidc_login_client_id = "nextcloud";
        oidc_login_client_secret = "insecure_secret";
        oidc_login_auto_redirect = false;
        oidc_login_end_session_redirect = false;
        oidc_login_button_text = "Log in with Authelia";
        oidc_login_hide_password_form = false;
        oidc_login_use_id_token = true;
        oidc_login_attributes = {
          id = "preferred_username";
          name = "name";
          mail = "email";
          groups = "groups";
        };
        oidc_login_default_group' = "oidc";
        oidc_login_use_external_storage = false;
        oidc_login_scope = "openid profile email groups";
        oidc_login_proxy_ldap = false;
        oidc_login_disable_registration = true;
        oidc_login_redir_fallback = false;
        oidc_login_tls_verify = true;
        oidc_create_groups = false;
        oidc_login_webdav_enabled = false;
        oidc_login_password_authentication = false;
        oidc_login_public_key_caching_time = 86400;
        oidc_login_min_time_between_jwks_requests = 10;
        oidc_login_well_known_caching_time = 86400;
        oidc_login_update_avatar = false;
        oidc_login_code_challenge_method = "S256";
      };
    };
  };
}
