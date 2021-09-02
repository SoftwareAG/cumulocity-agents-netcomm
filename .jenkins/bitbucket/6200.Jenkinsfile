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
        booleanParam(name: 'BUILD_NETCOMM_AGENT', defaultValue: false, description: 'Toggle this to build and upload NetComm Agent')
        booleanParam(name: 'BUILD_VNCPROXY', defaultValue: false, description: 'Toggle this to build and upload VNCPROXY')
        booleanParam(name: 'BUILD_CA_CUMULOCITY', defaultValue: false, description: 'Toggle this to build and upload ca-cumulocity')
    }
    stages {
        stage('Checkout') {
            steps {
                container('ansic') {
                    dir('c-sdk') {
                        git branch: "$sdkbranch", credentialsId: "jenkins-master", url:'git@bitbucket.org:m2m/cumulocity-sdk-c.git'
                        sh 'git submodule update --init --recursive'
                    }
                    dir('agent') {
                        git branch: "$agentbranch", credentialsId: "jenkins-master", url:'git@bitbucket.org:m2m/cumulocity-agents-netcomm.git'
                        sh 'git submodule update --init --recursive'
                    }
                }
            }
        }
        stage('Build SDK') {
            when {
                expression {return params.BUILD_NETCOMM_AGENT}
            }
            steps {
                container('ansic') {
                    dir('c-sdk') {
                        sh '''
                        export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_6200_2.0.36.10
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
            when {
                expression {return params.BUILD_NETCOMM_AGENT}
            }
            steps {
                container('ansic') {
                    sshagent (['jenkins-master']) {
                        dir('agent') {
                            sh '''
                            export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_6200_2.0.36.10
                            cp -rP ../c-sdk/lib ../c-sdk/bin .
                            make clean
                            C8Y_LIB_PATH=../c-sdk make BUILD=release
                            scp -o StrictHostKeyChecking=no ./build/test-smartrest-agent*.ipk hudson@resources.cumulocity.com:/resources/ntc/
                            '''
                        }
                    }
                }
            }
        }
        stage('Build vncproxy') {
            when {
                expression {return params.BUILD_VNCPROXY}
            }
            steps {
                container('ansic') {
                    sshagent (['jenkins-master']) {
                        dir('agent') {
                            sh '''
                            export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_6200_2.0.36.10
                            make clean
                            C8Y_LIB_PATH=../c-sdk make vnc BUILD=release
                            scp -o StrictHostKeyChecking=no ./build/vncproxy*.ipk hudson@resources.cumulocity.com:/resources/ntc/
                            '''
                        }
                    }
                }
            }
        }
        stage('Build ca-cumulocity') {
            when {
                expression {return params.BUILD_CA_CUMULOCITY}
            }
            steps {
                container('ansic') {
                    sshagent (['jenkins-master']) {
                        dir('agent') {
                            sh '''
                            export NTC_SDK_PATH=/opt/SDK_Bovine_ntc_6200_2.0.36.10
                            ./tools/mk-ca-cumulocity.sh pkg
                            scp -o StrictHostKeyChecking=no ./build/ca-cumulocity*.ipk hudson@resources.cumulocity.com:/resources/ntc/
                            '''
                        }
                    }
                }
            }
        }
    }
}
