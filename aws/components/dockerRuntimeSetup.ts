export const dockerRuntimeSetup =`
name: DockerRuntimeSetup
description: this document configures nvidia docker runtime
schemaVersion: 1.0

phases:
    - name: build
      steps:
        - name: ConfigureDockerRuntime
          action: ExecuteBash
          inputs:
            commands:        
                - |
                  sudo cat > /usr/libexec/docker/docker-setup-runtimes.sh <<EOF
                  #!/bin/sh
                  {
                    echo -n "DOCKER_ADD_RUNTIMES=\""
                    for file in /etc/docker-runtimes.d/*; do
                      [ -f "$file" ] && [ -x "$file" ] && echo -n "--add-runtime $(basename "$file")=$file "
                    done
                    echo -n "--default-runtime nvidia "
                    echo "\""
                  } > /run/docker/runtimes.env
                  EOF
`
