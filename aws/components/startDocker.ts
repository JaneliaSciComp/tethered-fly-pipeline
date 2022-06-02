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
`