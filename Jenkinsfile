pipeline {
    agent any
    environment {
        HAB_NOCOLORING = false
        HAB_BLDR_URL = 'https://bldr.habitat.sh/'
        HAB_ORIGIN = 'nrycar'
    }
    stages {
        stage('Clone from GitHub') {
            steps {
                git url: 'https://github.com/ChefRycar/sample-node-app.git', branch: 'master'
            }
        }
        stage('Build Chef Habitat Artifact') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    script {
                       sh 'hab origin key download --secret $HAB_ORIGIN -z $HAB_AUTH_TOKEN'
                       sh 'hab origin key download $HAB_ORIGIN'
                    }
                }
                habitat task: 'build', directory: '.', origin: "${env.HAB_ORIGIN}", docker: true
            }
        }
        stage('Upload to bldr.habitat.sh') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    script {
                       sh 'hab origin key download --secret $HAB_ORIGIN -z $HAB_AUTH_TOKEN'
                       sh 'hab origin key download $HAB_ORIGIN'
                    }
                    habitat task: 'upload', authToken: env.HAB_AUTH_TOKEN, lastBuildFile: "${workspace}/results/last_build.env", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Promote to Dev Channel') {
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/unstable/pkgs/sample-node-app/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "dev", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }

        stage('Wait for Deploy to Dev') {
            steps {
                sh '/usr/local/bin/deployment_status.sh sample-node-app sn dev dev' 
            }
        }
        stage('Check Dev Health') {
            steps {
                sh '/usr/local/bin/health_check.sh sample-node-app sn dev dev'
            }
        }
        stage('Promote to prod-canary Channel') {
            input {
                message "Ready to promote to prod (canary)?"
                ok "Sure am!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/dev/pkgs/sample-node-app/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "prod-canary", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Wait for Canary Deploy to Prod') {
            steps {
                sh '/usr/local/bin/deployment_status.sh sample-node-app sn prod prod-canary' 
            }
        }
        stage('Check Canary Health') {
            steps {
                sh '/usr/local/bin/health_check.sh sample-node-app sn prod prod-canary'
            }
        }
        stage('Promote to Prod (50%)') {
            input {
                message "Ready to promote to prod (50%)?"
                ok "Sure am!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/prod-canary/pkgs/sample-node-app/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "prod-50", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Wait for Canary Deploy to Prod (50%)') {
            steps {
                sh '/usr/local/bin/deployment_status.sh sample-node-app sn prod prod-50' 
            }
        }
        stage('Check Prod (50%) Health') {
            steps {
                sh '/usr/local/bin/health_check.sh sample-node-app sn prod prod-50'
            }
        }
        stage('Promote to Prod (100%)') {
            input {
                message "Ready to complete prod deploy?"
                ok "Sure am!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/prod-50/pkgs/sample-node-app/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "prod", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Wait for Canary Deploy to Prod (100%)') {
            steps {
                sh '/usr/local/bin/deployment_status.sh sample-node-app sn prod prod' 
            }
        }
        stage('Check Prod (100%) Health') {
            steps {
                sh '/usr/local/bin/health_check.sh sample-node-app sn prod prod'
            }
        }
        stage('Promote to Stable') {
            input {
                message "Promote to stable?"
                ok "Yup!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/prod/pkgs/sample-node-app/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "stable", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
    }
}
