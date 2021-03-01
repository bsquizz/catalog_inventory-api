class MqttClientTask < Task
  def dispatch
    catalog_inventory_url = ClowderConfig.instance["CATALOG_INVENTORY_EXTERNAL_URL"]
    cloud_connector_url = ClowderConfig.instance["CLOUD_CONNECTOR_URL"]
    app_version = ClowderConfig.instance["CURRENT_API_VERSION"] || "v1.0"

    task_url_prefix = File.join(catalog_inventory_url, app_version, "tasks").gsub(/^\/+|\/+$/, "")
    opts = {:task_id             => id,
            :task_url            => task_url_prefix,
            :mqtt_client_guid    => source.mqtt_client_id,
            :cloud_connector_url => cloud_connector_url}

    Rails.logger.info("Getting connection to cloud connector ...")
    MQTTControllerService.new(opts).process
  end
end
