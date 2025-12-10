pipeline {
    agent any

    parameters {
        choice name: 'ENV', choices: ['dev', 'prod'], description: 'Target environment'
        booleanParam name: 'APPLY', defaultValue: false, description: 'If true will run apply after plan'
    }

    environment {
        // credentials id names in Jenkins (create these)
        // the output of `az ad sp create-for-rbac --sdk-auth` stored as secret text
        ARM_CLIENT_ID       = credentials('clientid')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        GIT_CREDENTIALS = credentials('git-token')     // optional: Git token if repo private
        TF_WORKSPACE = "${params.ENV}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Agent') {
            steps {
                sh 'terraform --version || true'
                sh 'az --version || true'
            }
        }

        stage('Set Azure Auth') {
            steps {
                script {
                    // Write SDK auth to file; provider picks it up via ARM_AUTH_LOCATION or ARM_SDK_AUTH
                    sh '''
            echo "$AZURE_SDK_AUTH" > ./azure_credentials.json
            export ARM_AUTH_LOCATION=./azure_credentials.json
          '''
                }
            }
        }

        stage('Init') {
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Validate') {
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Plan') {
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform plan -out=tfplan -input=false'
                    sh 'terraform show -json tfplan > tfplan.json || true'
                    archiveArtifacts artifacts: "envs/${params.ENV}/tfplan.json", allowEmptyArchive: true
                }
            }
        }

        stage('Manual Approval for Prod') {
            when { expression { params.ENV == 'prod' } }
            steps {
                input message: "Approve apply to PROD?"
            }
        }

        stage('Apply') {
            when { expression { params.APPLY == true } }
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    success {
      echo "Pipeline succeeded"
    }
    failure {
      echo "Pipeline failed"
    }
    }
}
