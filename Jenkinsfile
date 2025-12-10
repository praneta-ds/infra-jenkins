pipeline {
    agent any

    parameters {
        choice name: 'ENV', choices: ['dev', 'prod'], description: 'Target environment'
        booleanParam name: 'APPLY', defaultValue: false, description: 'If true will run apply after plan'
        booleanParam name: 'DESTROY', defaultValue: false, description: 'Destroy environment'
    }

    environment {
        ARM_CLIENT_ID       = credentials('clientId')
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
                        sh 'terraform init'
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
        stage('Terraform Output') {
            steps {
                dir("envs/${params.ENV}") {
                    sh 'terraform output -json > output.json'
                    archiveArtifacts artifacts: 'output.json', fingerprint: true
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.DESTROY } }
            steps {
                dir("envs/${params.ENV}") {
                    // Manual confirmation before destroying resources
                    input message: "⚠️ Are you sure you want to DESTROY all resources in ${params.ENV}?"
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }

    success {
        script {
            emailext(
                to: 'pranetadashora@gmail.com',
                subject: "Jenkins Build Successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """The Jenkins build was successful.
                Check console output: ${env.BUILD_URL}"""
            )
        }
    }


        failure {
            emailext(
                to: 'pranetadashora@gmail.com',
                from: 'pranetadashora@gmail.com',
                subject: "Jenkins Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "The Jenkins build failed.\n\nCheck console output at: ${env.BUILD_URL}"
      
            )
        }
    }
}
