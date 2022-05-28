export const startDocker = `
name: StartDocker
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: StartDocker
        action: ExecuteBash
        inputs:
          commands:
            - systemctl start docker
      - name: StartDocker
        action: ExecuteBash
        inputs:
          commands:
            - systemctl stop ecs
            - rm -rf /var/lib/ecs/data/agent.db
`