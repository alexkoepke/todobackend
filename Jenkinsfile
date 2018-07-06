#!groovy​
pipeline {
  agent any
  environment {
      SITE_USER = 'groundsystems'
      SITE_ROOT = '/home/groundsystems/public_html'
      DEV_SERVER = 'root@bart.usdigitalpartners.net'
      BUILD_BRANCH = 'master'
  }
  stages {
  script {
    try {
          stage('Run unit/integration tests') {
              when {
                  branch 'master'
                  beforeAgent true
                  expression {
                      currentBuild.result == null || currentBuild.result == 'SUCCESS'
                  }
              }
              steps {
                  sh 'make test'
              }
          }
          stage('Build application artefacts') {
              when {
                  branch 'master'
                  beforeAgent true
                  expression {
                      currentBuild.result == null || currentBuild.result == 'SUCCESS'
                  }
              }
              steps {
                  sh 'make build'
              }
          }
          stage('Create release environment and run acceptance tests') {
              when {
                  branch 'master'
                  beforeAgent true
                  expression {
                      currentBuild.result == null || currentBuild.result == 'SUCCESS'
                  }
              }
              steps {
                  sh 'make release'

              }
          }
          stage('Tag and publish release image') {
              when {
                  branch 'master'
                  beforeAgent true
                  expression {
                      currentBuild.result == null || currentBuild.result == 'SUCCESS'
                  }
              }
              steps {
                  sh "make tag latest \$(git rev-parse --short HEAD) \$(git tag --points-at HEAD)"
                  sh "make buildtag master \$(git tag --points-at HEAD)"
                  withEnv(["DOCKER_USER=${DOCKER_USER}",
                          "DOCKER_PASSWORD=${DOCKER_PASSWORD}",
                          "DOCKER_EMAIL=${DOCKER_EMAIL}"]) {    
                      sh "make login"
                  }
                  sh "make publish"
              }
          }
          stage('Deploy release') {
              when {
                  branch 'master'
                  beforeAgent true
                  expression {
                      currentBuild.result == null || currentBuild.result == 'SUCCESS'
                  }
              }
              steps {
                sh "printf \$(git rev-parse --short HEAD) > tag.tmp"
                def imageTag = readFile 'tag.tmp'
                build job: DEPLOY_JOB, parameters: [[
                    $class: 'StringParameterValue',
                    name: 'IMAGE_TAG',
                    value: 'jmenga/todobackend:' + imageTag
                ]]
              }
          }
    }
    finally {
        stage('Collect test reports') {
          steps {
            step([$class: 'JUnitResultArchiver', testResults: '**/reports/*.xml'])
          }
        }
        stage('Clean up') {
          steps {
            sh 'make clean'
            sh 'make logout'
          }
        }
      }
    }
  }
}