class LaunchJobTask < MqttClientTask
  after_update :post_launch_job_task, :if => proc { type == 'LaunchJobTask' && state == 'completed' }

  def post_launch_job_task
    PostLaunchJobTaskService.new(service_options).process
  end

  def service_options
    {}.tap do |options|
      options[:tenant_id] = tenant.id
      options[:source_id] = source.id
      options[:service_offering_id] = service_offering_id.to_s
      options[:service_plan_id] = service_plan_id.to_s
      options[:external_url] = output["url"]
      options[:source_ref] = output["id"]
      options[:name] = output["name"]
      options[:source_created_at] = output["created"]
      options[:extra] = extra
    end
  end

  def extra
    {}.tap do |e|
      e[:status] = output["status"]
      e[:started] = output["started"]
      e[:finished] = output["finished"]
      e[:extra_vars] = output["extra_vars"]
      e[:artifacts] = output["artifacts"]
    end
  end

  def service_offering_id
    @service_offering_id ||= ServiceOffering.find_by(:source_ref => output["unified_job_template"].to_s).id
  end

  def service_plan_id
    ServiceOffering.find(service_offering_id).service_plans.first.id
  end
end
