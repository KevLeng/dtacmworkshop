@Library('keptn-library')_
def keptn = new sh.keptn.Keptn()


pipeline {
    agent {
        label 'jenkins-slave'
    }
    parameters {
        choice(name: 'BUILD', choices: ['One', 'Two'], description: 'Choose Build')
    }

    stages{
        stage('Checkout code'){
            steps{
                //git 'https://github.com/dynatrace-acm/dtacmworkshop.git'
                git 'https://github.com/KevLeng/dtacmworkshop.git'
            }
        }
        stage('Initialize Keptn') {
            steps{
                script{
                    echo 'Initialize Keptn...'
                    sh 'ls'
            
                    // Initialize the Keptn Project
                    //keptn.keptnInit project:"${params.Project}", service:"${params.Service}", stage:"${params.Stage}", monitoring:"${monitoring}" // , shipyard:'shipyard.yaml'
                    keptn.keptnInit project:"krl-ace", service:"carts", stage:"dev", monitoring:"dynatrace" // , shipyard:'shipyard.yaml'
            
                    // Upload all the files
                    keptn.keptnAddResources('manifests/keptn/dynatrace.conf.yaml','dynatrace/dynatrace.conf.yaml')
                    keptn.keptnAddResources('manifests/keptn/sli_basic.yaml','dynatrace/sli.yaml')
                    keptn.keptnAddResources('manifests/keptn/slo_basic.yaml','slo.yaml')
                    archiveArtifacts artifacts:'manifests/keptn/**/*.*'
                }
            }
        }
        stage('Build Code') {
            steps{
                container('mvn'){
                    echo 'Code Building...'
                    script {
                        sh 'mvn -v'
                    }
                    //sleep 20    
                }
            }
        }
        stage('Build Image'){
            steps{
                container('docker'){
                    echo 'Image Building...'
                    script{
                        sh 'docker'
                    }
                    //sleep 20
                }
            }
        }
        stage('Push Image to Repo'){
            steps{
                container('docker'){
                    echo 'Pushing Image...'
                    script{
                        sh 'docker'
                    }
                    //sleep 20
                }
            }
        }
        stage('Deploy to Staging'){
            steps{
                container('kubectl'){
                    echo 'Deployment canary build...'
                    script{
                        if (params.BUILD == "One") {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/dev/carts2.yml'
                            echo "Waiting for carts service to start..."
                            // need a method to check carts rediness
                            sleep 15
                        } else {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/canary/carts2-canary.yml'
                            echo "Waiting for carts service to start..."
                            sleep 20
                        }
                    }
                }
            }
        }
        stage ('Run Load Test'){
            steps{
                container('kubectl'){
                    echo 'Get Carts URL'
                    script{
                        dir("loadtest"){
                            sh "chmod +x cartstest.sh"
                            sh "./cartstest.sh"
                            
                        }
                    }
                }
                /*container('curl'){
                    script{
                        dir("loadtest"){
                            sh "chmod +x loadtest.sh"
                            sh "./loadtest.sh"
                        }
                    }
                }*/
                container('jmeter'){
                    script{
                        ///keptn mark evaluation time
                        keptn.markEvaluationStartTime()
                        if (params.BUILD == "One"){
                            dir("loadtest"){
                                sh "jmeter -n -t carts_load1.jmx -l testresults.jtl"
                            }   
                        } else {
                            dir("loadtest"){
                                sh "jmeter -n -t carts_load2.jmx -l testresults.jtl"
                            } 
                        }
                        
                    }
                }
            }
        }
        stage('Trigger Quality Gate') {
            steps {
                script{
                    echo "Quality Gates ONLY: Just triggering an SLI/SLO-based evaluation for the passed timeframe"


                    // Trigger an evaluation. It will take the starttime from our call to markEvaluationStartTime and will Now() as endtime
                    def keptnContext = keptn.sendStartEvaluationEvent starttime:"", endtime:""
                    String keptn_bridge = env.KEPTN_BRIDGE
                    echo "Open Keptns Bridge: ${keptn_bridge}/trace/${keptnContext}"
                    sleep 120
                    waitTime = 5
                    if(params.WaitForResult?.isInteger()) {
                        waitTime = params.WaitForResult.toInteger()
                    }
            
                    if(waitTime > 0) {
                        echo "Waiting until Keptn is done and returns the results"
                        def result = keptn.waitForEvaluationDoneEvent setBuildResult:true, waitTime:waitTime
                        echo "${result}"
                    } else {
                        echo "Not waiting for results. Please check the Keptns bridge for the details!"
                    }
                }
            }
        }
        stage ('Deploy to Production'){
            steps{
                container('kubectl'){
                    echo 'Deploying to Production'
                    script{
                        if (params.BUILD == "One") {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/production/carts2.yml'
                            echo "Waiting for carts service to start..."
                            /// need to check carts rediness
                            sleep 30
                        } else {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/canary/carts2-badbuild.yml'
                            echo "Waiting for carts service to start..."
                            sleep 30
                        }
                    }
                }
            }
        }
    }
}