# --- Configuration ---
# This is the correct, documented way to handle selective resource startup in Tilt.
# We define that we accept a list of positional string arguments.
# Usage: tilt up servicea serviceb
config.define_string_list('services', args=True)

# Parse the config from the command line.
cfg = config.parse()

# Get the list of services to run from the parsed config.
services_to_run = cfg.get('services', [])

# --- Helm Configuration ---
# Dynamically create --set arguments for Helm based on the services requested.
set_flags = []
all_services_in_values = ['serviceA', 'serviceB'] # Must match the names in values.yaml

# If no services are specified, we don't need to add any --set flags,
# as Helm will use the defaults from values.yaml.
if services_to_run:
    for service_name in all_services_in_values:
        # Check if the lowercase version of the service name is in our list
        if service_name.lower() in services_to_run:
            set_flags.append(service_name + '.enabled=true')
        else:
            set_flags.append(service_name + '.enabled=false')

# --- Resource Definitions ---
docker_build('my-repo/service-a', 'services/service-a')
docker_build('my-repo/service-b', 'services/service-b')

k8s_yaml(helm(
    './helm/app',
    name='main-app',
    values=['./helm/app/values.yaml', './helm/app/secrets.yaml'],
    set=set_flags
))

# --- Port Forwards ---
# These will now work correctly, as they will only be applied to
# resources that actually get created by the Helm chart.
k8s_resource('main-app-service-a', port_forwards='8080:80')
k8s_resource('main-app-service-b', port_forwards='8081:80')
k8s_resource('main-app-service-a-db', port_forwards='5433:5432')
k8s_resource('main-app-service-b-db', port_forwards='5432:5432')