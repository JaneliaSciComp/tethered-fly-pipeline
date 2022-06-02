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
            - rm -rf /var/lib/ecs/data/agent.db
      - name: ConfigureECS
        action: ExecuteBash
        inputs:
          commands:
            - mkdir -p /etc/ecs
            - echo ECS_IMAGE_PULL_BEHAVIOR=once >> /etc/ecs/ecs.config
            - echo ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE=true >> /etc/ecs/ecs.config
`
