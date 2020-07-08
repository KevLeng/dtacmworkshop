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
                }
            }
        }
        stage('Build Image'){
            steps{
                container('docker'){
                    echo 'Image Building...'
                }
            }
        }
        stage('Push Image to Repo'){
            steps{
                container('docker'){
                    echo 'Pushing Image...'
                }
            }
        }
        stage('Deploy to Staging'){
            steps{
                container('kubectl'){
                    echo 'Deployment build...'
                    script{
                        if (params.BUILD == "One") {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/dev/carts2.yml'
                            echo "Waiting for carts service to start..."
                            // need a method to check carts rediness
                        } else {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/canary/carts2-canary.yml'
                            echo "Waiting for carts service to start..."
                        }
                        sleep 10
                        container('kubectl'){
                            echo "Get carts IP from kubectl..."
                            cartsIp = sh (returnStdout:true, script:"kubectl describe svc carts -n dev | grep \'LoadBalancer Ingress:\' | sed \'s~LoadBalancer Ingress:[ \t]*~~\'").trim()
                            echo "carts IP address is ${cartsIp}"
                        }
                        def serviceResponse = ""
                        timeout(time: 10, unit: 'MINUTES') {
                            script {
                                waitUntil {
                                    // get carts url 
                                    def response = httpRequest httpMode: 'GET', 
                                        responseHandle: 'STRING', 
                                        url: "http://${cartsIp}/", 
                                        validResponseCodes: "100:500"
                    
                                    //The API returns a response code 500 error if the evalution done event does not exisit
                                    if (response.status != 200 ) {
                                        echo "Waiting for carts service to start, ip address: ${cartsIp}"
                                        sleep 20
                                        return false
                                    } else {
                                        serviceResponse = response.content
                                        echo "Carts service started."
                                        return true
                                    } 
                                }
                            }
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
                script{
                    container('kubectl'){
                         echo "Get carts IP from kubectl..."
                         cartsIp = sh (returnStdout:true, script:"kubectl describe svc carts -n dev | grep \'LoadBalancer Ingress:\' | sed \'s~LoadBalancer Ingress:[ \t]*~~\'").trim()
                         echo "carts IP address is ${cartsIp}"
                    }
                    
                     if (params.BUILD == "One"){
                            keptn.keptnAddResources('loadtest/carts_load1.jmx','jmeter/load.jmx')
                        } else {
                            keptn.keptnAddResources('loadtest/carts_load2.jmx','jmeter/load.jmx')
                        }
                    keptn.keptnAddResources('manifests/keptn/jmeter.conf.yaml','jmeter/jmeter.conf.yaml')
                    archiveArtifacts artifacts:'loadtest/**/*.*'
                    echo "Performance as a Self-Service: Triggering Keptn to execute Tests"

                    // send deployment finished to trigger tests
                    def keptnContext = keptn.sendDeploymentFinishedEvent testStrategy:"performance", deploymentURI:cartsIp 

                    String keptn_bridge = env.KEPTN_BRIDGE
                    echo "Open Keptns Bridge: ${keptn_bridge}/trace/${keptnContext}"

                }
            }
        }
        stage('Trigger Quality Gate') {
            steps {
                script{
                    echo "Quality Gates ONLY: Just triggering an SLI/SLO-based evaluation for the passed timeframe"

                    sleep 120
                    waitTime = 2
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
                        } else {
                            sh 'ls $WORKSPACE'
                            sh 'kubectl apply -f $WORKSPACE/manifests/sockshop-app/canary/carts2-badbuild.yml'
                            echo "Waiting for carts service to start..."
                        }
                        sleep 20
                    }
                }
            }
        }
    }
}