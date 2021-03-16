pipeline {
    agent {
        kubernetes {
            inheritFrom 'c8y-centos-ansic-bovine'
            defaultContainer 'ansic'
        }
    }
    parameters {
        string(name: 'agentbranch', defaultValue:'master', description: "Netcomm Agent's branch to be tested")
        string(name: 'sdkbranch', defaultValue: 'master', description: "C++ SDK's branch")
    }
    stages {
        stage('Checkout') {
            steps {
                container('ansic') {
                    dir('c-sdk') {
                        git branch: "$sdkbranch", credentialsId: "jenkins-hg-key", url:'git@bitbucket.org:m2m/cumulocity-sdk-c.git'
                        sh 'git submodule update --init --recursive'
                    }
                    dir('agent') {
                        git branch: "$agentbranch", credentialsId: "jenkins-hg-key", url:'git@bitbucket.org:m2m/cumulocity-agents-netcomm.git'
                        sh 'git submodule update --init --recursive'
                    }
                }
            }
        }
        stage('Build SDK') {
            steps {
                container('ansic') {
                    dir('c-sdk') {
                        sh '''
                        export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_220_2.0.99.0
                        cp Makefile.template Makefile
                        cp ../agent/init.mk init.mk
                        make clean
                        make release   
                        '''
                    }
                }
            }
        }
        stage('Build Netcomm Agent') {
            steps {
                container('ansic') {
                    withCredentials([file(credentialsId: 'netcomm-cumulocity-public-key', variable: 'PUBLIC_KEY')]){
                        dir('agent') {
                            sh '''
                            export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_220_2.0.99.0
                            mkdir -p misc/ipkkeys/
                            cp \$PUBLIC_KEY misc/ipkkeys/cumulocity-public.pem
                            cp -rP ../c-sdk/lib ../c-sdk/bin .
                            make clean
                            C8Y_LIB_PATH=../c-sdk make BUILD=release
                            '''
                        }
                    }
                }
            }
        }
        stage('Sign the agent package and upload') {
            steps {
                container('ansic') {
                    withCredentials([file(credentialsId: 'netcomm-cumulocity-private-key', variable: 'PRIVATE_KEY')]) {
                        sshagent (['jenkins-hg-key']) {
                            dir('agent') {
                                sh '''
                                export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_220_2.0.99.0
                                mkdir -p misc/ipkkeys/
                                cp \$PRIVATE_KEY misc/ipkkeys/cumulocity-private.pem
                                ./tools/mk-signed-ipk.sh build/cumulocity-ntc-agent_*_arm.ipk
                                scp -o StrictHostKeyChecking=no ./build/cumulocity-ntc-agent_*_arm-signed.ipk hudson@resources.cumulocity.com:/resources/ntc/
                                '''
                            }
                        }
                    }
                }
            }
        }
    }
}