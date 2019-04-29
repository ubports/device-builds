pipeline {
  agent {
    label "amd64"
  }
  triggers {
    cron("0 0 * * 2")
  }
  environment {
    SYSTEM_IMAGE_SERVER="https://system-image.ubports.com"
  }
  stages {
    stage ("Build check image") {
      steps {
        script {
          dockerImage = docker.build("build-scripts:${env:BUILD_ID}")
        }
      }
    }
    stage ("Checks") {
      parallel {
        stage ("Keys") {
          steps {
            script {
              withEnv(["HOME=${env.WORKSPACE}"]) {
                dockerImage.inside() {
                  sh("./check-gpg.sh ${env.SYSTEM_IMAGE_SERVER}")
                }
              }
            }
          }
        }
      }
    }
  }
  post {
    always {
      deleteDir()
    }
  }
}
