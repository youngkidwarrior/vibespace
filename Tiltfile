# -*- mode: Python -*-
# Direct Tilt setup for Vibespace backend development.
#
# TODO: Revisit the Cos Silo flow if multiple agents or local environments start
# fighting over ports, cluster contexts, registries, or generated env state.

load('ext://dotenv', 'dotenv')
load('ext://restart_process', 'docker_build_with_restart')
load('ext://uibutton', 'cmd_button')

if os.path.exists('.env.local'):
    dotenv('.env.local')
    watch_file('.env.local')
elif os.path.exists('.localnet.env'):
    dotenv('.localnet.env')
    watch_file('.localnet.env')
elif config.tilt_subcommand != 'down':
    fail('Vibespace localnet is not configured. Run `yarn localnet:up` to generate .env.local and start Tilt.')

if os.path.exists('.localnet.env'):
    watch_file('.localnet.env')

if os.path.exists('.env.secrets.local'):
    dotenv('.env.secrets.local')
    watch_file('.env.secrets.local')

def load_private_envrc(fn):
    watch_file(fn)
    if not os.path.exists(fn):
        return

    lines = str(read_file(fn)).splitlines()
    line_number = 0
    while line_number < len(lines):
        line = lines[line_number].strip()
        line_number += 1
        if not line or line.startswith('#'):
            continue
        if line.startswith('export '):
            line = line[len('export '):].strip()

        parts = line.split('=', 1)
        if len(parts) < 2:
            warn('Skipping unsupported .envrc.private line %s. Use simple `export KEY=value` assignments for Tilt.' % line_number)
            continue

        var_name = parts[0].strip()
        var_value = parts[1].strip()
        if '$(' in var_value or '`' in var_value:
            warn('Skipping shell expression for %s in .envrc.private. Run `direnv allow` and restart localnet so direnv can evaluate it.' % var_name)
            continue
        if var_value.startswith('"') and var_value.endswith('"'):
            var_value = var_value[1:-1]
        elif var_value.startswith("'") and var_value.endswith("'"):
            var_value = var_value[1:-1]

        os.putenv(var_name, var_value)

if os.path.exists('.envrc.private'):
    load_private_envrc('.envrc.private')
else:
    watch_file('.envrc.private')

http_port = os.getenv('HTTP_PORT', '4555')
postgres_port = os.getenv('POSTGRES_PORT', '5432')
postgres_password = os.getenv('POSTGRES_PASSWORD', 'vibespace')
frontend_port = os.getenv('FRONTEND_PORT', '5177')
graphql_public_url = 'http://127.0.0.1:%s/graphql' % http_port
frontend_graphql_endpoint = graphql_public_url
openai_api_key = os.getenv('OPENAI_API_KEY', '')
send_supabase_url = os.getenv('SEND_SUPABASE_URL', '')
send_supabase_anon_key = os.getenv('SEND_SUPABASE_ANON_KEY', '')
session_secret = os.getenv('VIBESPACE_SESSION_SECRET', '')
dev_admin_token = os.getenv('VIBESPACE_DEV_ADMIN_TOKEN', '')

k3d_registry = os.getenv('K3D_REGISTRY_NAME', '')
image_name = 'vibespace-backend'
if k3d_registry:
    image_name = '%s/vibespace-backend' % k3d_registry

docker_check = str(local('which docker 2>/dev/null || true', quiet=True)).strip()
if not docker_check:
    fail('Docker is required for Vibespace Tilt development. Install/start Docker, then rerun tilt up.')

kubeconfig = os.getenv('KUBECONFIG', '')
if not kubeconfig and config.tilt_subcommand != 'down':
    fail('KUBECONFIG is not set. Run `yarn localnet:up` so gen-env can create an isolated .k8s/kubeconfig.')

if kubeconfig and not os.path.exists(kubeconfig):
    fail('KUBECONFIG points to a missing file: %s. Run `yarn localnet:up` to regenerate localnet.' % kubeconfig)

expected_context = os.getenv('K8S_CONTEXT', '')
if kubeconfig:
    kubectl_context = str(local('kubectl --kubeconfig "%s" config current-context 2>/dev/null || true' % kubeconfig, quiet=True)).strip()
    if not kubectl_context and config.tilt_subcommand != 'down':
        fail('kubectl has no current context in %s. Run `yarn localnet:up` to recreate the local k3d cluster.' % kubeconfig)
    if expected_context and kubectl_context and kubectl_context != expected_context:
        fail('kubectl context mismatch. Expected %s from .env.local but got %s.' % (expected_context, kubectl_context))

pg_isready_check = str(local('which pg_isready 2>/dev/null || true', quiet=True)).strip()
if not pg_isready_check:
    fail('pg_isready is required for Vibespace DB codegen. Enter the Nix shell or install PostgreSQL client tools.')

watchman_check = str(local('which watchman 2>/dev/null || true', quiet=True)).strip()
if not watchman_check:
    fail('watchman is required for RescriptRelay watch mode. Enter the Nix shell or install Watchman.')

def yaml_double_quote(value):
    return str(value).replace('\\', '\\\\').replace('"', '\\"')

k8s_yaml(blob('''
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: vibespace-postgres-data
  labels:
    app: vibespace-postgres
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vibespace-postgres
  labels:
    app: vibespace-postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vibespace-postgres
  template:
    metadata:
      labels:
        app: vibespace-postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16-alpine
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_DB
              value: vibespace
            - name: POSTGRES_USER
              value: vibespace
            - name: POSTGRES_PASSWORD
              value: "%s"
            - name: PGDATA
              value: /var/lib/postgresql/data/pgdata
          readinessProbe:
            exec:
              command: ["pg_isready", "-U", "vibespace", "-d", "vibespace"]
            initialDelaySeconds: 5
            periodSeconds: 5
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: vibespace-postgres-data
---
apiVersion: v1
kind: Service
metadata:
  name: vibespace-postgres
  labels:
    app: vibespace-postgres
spec:
  selector:
    app: vibespace-postgres
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vibespace-backend
  labels:
    app: vibespace-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vibespace-backend
  template:
    metadata:
      labels:
        app: vibespace-backend
    spec:
      containers:
        - name: backend
          image: "%s"
          ports:
            - name: http
              containerPort: 3000
          env:
            - name: PORT
              value: "3000"
            - name: DATABASE_URL
              value: "postgres://vibespace:%s@vibespace-postgres:5432/vibespace?sslmode=disable"
            - name: OPENAI_API_KEY
              value: "%s"
            - name: SEND_SUPABASE_URL
              value: "%s"
            - name: SEND_SUPABASE_ANON_KEY
              value: "%s"
            - name: VIBESPACE_GRAPHQL_PUBLIC_URL
              value: "%s"
            - name: VIBESPACE_SESSION_SECRET
              value: "%s"
            - name: VIBESPACE_DEV_ADMIN_TOKEN
              value: "%s"
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: vibespace-backend
  labels:
    app: vibespace-backend
spec:
  selector:
    app: vibespace-backend
  ports:
    - name: http
      port: 3000
      targetPort: 3000
''' % (
    yaml_double_quote(postgres_password),
    image_name,
    yaml_double_quote(postgres_password),
    yaml_double_quote(openai_api_key),
    yaml_double_quote(send_supabase_url),
    yaml_double_quote(send_supabase_anon_key),
    yaml_double_quote(graphql_public_url),
    yaml_double_quote(session_secret),
    yaml_double_quote(dev_admin_token),
)))

local_resource(
    'schema-watch',
    cmd='',
    serve_cmd='yarn rescript:backend:watch',
    resource_deps=['db-codegen'],
    labels=['backend'],
)

local_resource(
    'resgraph-lsp',
    cmd='',
    serve_cmd='yarn workspace @vibespace/graphql resgraph:lsp',
    resource_deps=['schema-watch'],
    labels=['backend'],
)

local_resource(
    'relay-watch',
    cmd='',
    serve_cmd='yarn relay:watch',
    resource_deps=['resgraph-lsp'],
    labels=['frontend'],
)

local_resource(
    'router-watch',
    cmd='',
    serve_cmd='yarn router:watch',
    labels=['frontend'],
)

local_resource(
    'rescript-watch',
    cmd='',
    serve_cmd='yarn rescript:watch',
    resource_deps=['relay-watch', 'router-watch'],
    labels=['frontend'],
)

local_resource(
    'vite',
    cmd='',
    serve_cmd='''set -eu
export VITE_GRAPHQL_ENDPOINT="%s"
yarn workspace @vibespace/web vite --host 127.0.0.1 --port "%s"
''' % (frontend_graphql_endpoint, frontend_port),
    resource_deps=['rescript-watch', 'server'],
    links=[link('http://127.0.0.1:%s/' % frontend_port, 'app')],
    labels=['frontend'],
)

local_resource(
    'reanalyze',
    cmd='yarn reanalyze:report',
    auto_init=False,
    trigger_mode=TRIGGER_MODE_MANUAL,
    labels=['analysis'],
)

def reanalyze_button(suffix, script, text, icon_name='analytics'):
    cmd_button(
        'reanalyze:%s' % suffix,
        argv=['sh', '-c', 'yarn %s' % script],
        resource='reanalyze',
        icon_name=icon_name,
        text=text,
    )

reanalyze_button('dead-code', 'reanalyze', 'Dead code')
reanalyze_button('dead-code-json', 'reanalyze:json', 'Dead code JSON', 'data_object')
reanalyze_button('report', 'reanalyze:report', 'Budget report', 'fact_check')
reanalyze_button('report-allow', 'reanalyze:report:allow', 'Budget report +10', 'rule')
reanalyze_button('exceptions', 'reanalyze:exception', 'Exceptions', 'warning')
reanalyze_button('exceptions-json', 'reanalyze:exception:json', 'Exceptions JSON', 'data_object')
reanalyze_button('reactive', 'reanalyze:reactive', 'Reactive', 'bolt')
reanalyze_button('benchmark', 'reanalyze:benchmark', 'Benchmark', 'speed')
reanalyze_button('mermaid', 'reanalyze:mermaid', 'Mermaid graph', 'account_tree')

local_resource(
    'db-codegen',
    cmd='''set -eu
export PGHOST=127.0.0.1
export PGPORT="%s"
export PGDATABASE=vibespace
export PGUSER=vibespace
export PGPASSWORD="%s"
export POSTGRES_PASSWORD="$PGPASSWORD"

until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE"; do
  sleep 1
done

yarn db:schema:bootstrap
PGSCHEMA_APPLY_MODE=file yarn db:schema:apply
yarn pgtyped
''' % (postgres_port, postgres_password),
    deps=[
        './db/bootstrap',
        './db/schemas',
        './db/queries/profile_versions.sql',
        './api/graphql/src/BackendServer.res',
        './api/graphql/rescript.json',
        './api/graphql/resgraph.json',
        './packages/schema/src/BackendNodeResolvers.res',
        './packages/schema/src/BackendSchema.res',
        './packages/schema/src/ResGraphContext.res',
        './packages/schema/rescript.json',
        './apps/web/relay.config.json',
        './apps/web/rescriptRelayRouter.config.cjs',
        './pgtyped.config.json',
        './scripts/db-schema-apply.sh',
        './scripts/db-schema-bootstrap.sh',
        './scripts/db-schema-env.sh',
        './scripts/relay-no-watchman.sh',
        './api/graphql/package.json',
        './apps/web/package.json',
        './packages/schema/package.json',
        './package.json',
        './yarn.lock',
        './.yarnrc.yml',
    ],
    resource_deps=['postgres'],
    labels=['database'],
)

local_resource(
    'pgtyped-watch',
    cmd='',
    serve_cmd='''set -eu
export PGHOST=127.0.0.1
export PGPORT="%s"
export PGDATABASE=vibespace
export PGUSER=vibespace
export PGPASSWORD="%s"
export POSTGRES_PASSWORD="$PGPASSWORD"

until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE"; do
  sleep 1
done

npx pgtyped-rescript -w -c pgtyped.config.json
''' % (postgres_port, postgres_password),
    resource_deps=['db-codegen'],
    labels=['database'],
)

docker_build_with_restart(
    image_name,
    '.',
    dockerfile='Dockerfile',
    entrypoint=['bun', 'api/graphql/src/BackendServer.res.js'],
    ignore=[
        '.direnv',
        '.git',
        '.home',
        '.npm-cache',
        '.vite',
        '.yarn/cache',
        'api/graphql/lib',
        'apps/web/dist',
        'apps/web/lib',
        'apps/web/node_modules',
        'apps/web/node_modules/.vite',
        'apps/web/node_modules/.vite-temp',
        'apps/web/src/**/*.bs.js',
        'apps/web/src/**/*.bs.js.map',
        'apps/web/src/**/*.res.js',
        'apps/web/src/**/*.res.js.map',
        'packages/generative-ui/lib',
        'packages/schema/lib',
        'dist',
        'lib',
        'node_modules',
        '*.bs.js',
        '*.bs.js.map',
        '*.llm.txt',
        '*.res.js',
        '*.res.js.map',
    ],
    live_update=[
        fall_back_on([
            './package.json',
            './yarn.lock',
            './.yarnrc.yml',
            './Dockerfile',
            './db/bootstrap',
            './db/schemas',
            './api/graphql/package.json',
            './api/graphql/rescript.json',
            './api/graphql/resgraph.json',
            './packages/schema/package.json',
            './packages/schema/rescript.json',
            './packages/generative-ui/package.json',
            './apps/web/package.json',
        ]),
        sync('./api/graphql/src', '/app/api/graphql/src'),
        sync('./packages/generative-ui/src', '/app/packages/generative-ui/src'),
        sync('./packages/schema/src', '/app/packages/schema/src'),
        sync('./db', '/app/db'),
    ],
)

k8s_resource(
    workload='vibespace-postgres',
    new_name='postgres',
    extra_pod_selectors={'app': 'vibespace-postgres'},
    discovery_strategy='selectors-only',
    port_forwards=[postgres_port + ':5432'],
    labels=['database'],
)

k8s_resource(
    objects=['vibespace-postgres-data:persistentvolumeclaim'],
    new_name='postgres-storage',
    labels=['database'],
)

k8s_resource(
    workload='vibespace-backend',
    new_name='server',
    extra_pod_selectors={'app': 'vibespace-backend'},
    discovery_strategy='selectors-only',
    port_forwards=[http_port + ':3000'],
    links=[link('http://127.0.0.1:%s/graphql' % http_port, 'graphql')],
    resource_deps=['postgres', 'db-codegen', 'resgraph-lsp'],
    labels=['backend'],
)
