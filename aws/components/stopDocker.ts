export const stopDocker = `
name: StopDocker
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: StopDocker
        action: ExecuteBash
        inputs:
          commands:
            - systemctl stop docker
            - systemctl stop ecs
`
