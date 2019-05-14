# ci-alpine
Continuous Integration (CI) build container, based on alpine.

## Usage

### On Semaphore 2.0 pipelines:

Example pipeline file to deploy over ssh, including decryption of application secrets used in `.env`.

```(yaml)
version: v1.0
name: Deploy
agent:
  machine:
    type: e1-standard-2
    os_image: ubuntu1804
  containers:
    - name: main
      image: simplificator/ci-alpine

blocks:
  - name: "Deploy"
    task:
      env_vars:
        - name: SSH_USER_AT_HOST
          value: butler@my-app.example.com
        - name: SSH_IDENTITY
          # injected via semaphore secret
          value: /home/semaphore/.ssh/id_rsa_deploy
        - name: SSH_OPTIONS
          value: -o StrictHostKeyChecking=no
        - name: SECRET_FILE_ENC
          # injected via semaphore secret
          value: deploy/.env.stag.enc
      secrets:
        - name: my-deployer-secrets
      prologue:
        commands:
          - checkout
          - chmod 400 $SSH_IDENTITY
          - ssh-add $SSH_IDENTITY
          - libressl aes-128-cbc -d -salt -in $SECRET_FILE_ENC -out deploy/.env -k $SECRET_ENCRYPTION_KEY
      jobs:
        - name: Deploy
          commands:
            - "scp $SSH_OPTIONS deploy/deploy.sh $SSH_USER_AT_HOST:"
            - "scp $SSH_OPTIONS deploy/docker-compose.yml $SSH_USER_AT_HOST:"
            - "scp $SSH_OPTIONS deploy/.env $SSH_USER_AT_HOST:"
            - ssh $SSH_OPTIONS $SSH_USER_AT_HOST sh deploy.sh

```


## References

[Custom CI/CD environment on Semaphore 2.0](https://docs.semaphoreci.com/article/127-custom-ci-cd-environment-with-docker)
