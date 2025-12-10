pipeline {
    agent any

    parameters {
        choice name: 'ENV', choices: ['dev', 'prod'], description: 'Target environment'
        booleanParam name: 'APPLY', defaultValue: false, description: 'If true will run apply after plan'
    }

    environment {
        ARM_CLIENT_ID       = credentials('clientid')
        ARM_CLIENT_SECRET   = credentials('azure-client-secret')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        TF_WORKSPACE        = "${params.ENV}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check Tools') {
            steps {
                sh 'terraform --version'
                sh 'az --version'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("envs/${params.ENV}") {
                    withEnv([
                        "ARM_CLIENT_ID=${env.ARM_CLIENT_ID}",
                        "ARM_CLIENT_SECRET=${env.ARM_CLIENT_SECRET}",
                        "ARM_SUBSCRIPTION_ID=${env.ARM_SUBSCRIPTION_ID}",
                        "ARM_TENANT_ID=${env.ARM_TENANT_ID}"
                    ]) {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("envs/${params.ENV}") {
                    withEnv([
                        "ARM_CLIENT_ID=${env.ARM_CLIENT_ID}",
                        "ARM_CLIENT_SECRET=${env.ARM_CLIENT_SECRET}",
                        "ARM_SUBSCRIPTION_ID=${env.ARM_SUBSCRIPTION_ID}",
                        "ARM_TENANT_ID=${env.ARM_TENANT_ID}"
                    ]) {
                        sh 'terraform plan -out=tfplan -input=false'
                        sh 'terraform show -json tfplan > tfplan.json'
                        archiveArtifacts artifacts: 'tfplan.json', allowEmptyArchive: true
                    }
                }
            }
        }

        stage('Manual Approval for Prod') {
            when { expression { params.ENV == 'prod' } }
            steps {
                input message: "Approve apply to PROD?"
            }
        }

        stage('Terraform Apply') {
            when { expression { params.APPLY == true } }
            steps {
                dir("envs/${params.ENV}") {
                    withEnv([
                        "ARM_CLIENT_ID=${env.ARM_CLIENT_ID}",
                        "ARM_CLIENT_SECRET=${env.ARM_CLIENT_SECRET}",
                        "ARM_SUBSCRIPTION_ID=${env.ARM_SUBSCRIPTION_ID}",
                        "ARM_TENANT_ID=${env.ARM_TENANT_ID}"
                    ]) {
                        sh 'terraform apply -input=false -auto-approve tfplan'
                    }
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
