
podTemplate(
  name: 'build-pod',
  label: 'build-pod',
  containers: [
      // containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave:latest',args: '${computer.jnlpmac} ${computer.name}', workingDir: '/home/jenkins'),
      containerTemplate(name: 'terraform', image: 'hashicorp/terraform:latest', ttyEnabled: true, command: 'cat', workingDir: '/home/jenkins'),
      containerTemplate(name: 'docker', image:'trion/jenkins-docker-client')
  ],
  envVars: [
      envVar(key:'TF_VAR_region', value:'us-phoenix-1'),
      envVar(key:'TF_VAR_compartment_ocid', value:'ocid1.tenancy.oc1..aaaaaaaawpqblfemtluwxipipubxhioptheej2r32gvf7em7iftkr3vd2r3a')
  ],
  volumes: [
      hostPathVolume(mountPath: '/var/run/docker.sock',hostPath: '/var/run/docker.sock')
      ]
  ){
    //node = the pod label
    node('build-pod'){
      stage('Checkout') {
        checkout scm
      }
      //container = the container label
      stage('Test Example-1') { 
        container('terraform') {
          withCredentials([string(credentialsId: 'tenancy_ocid', variable: 'TF_VAR_tenancy_ocid'), string(credentialsId: 'user_ocid_jeevan', variable: 'TF_VAR_user_ocid'), string(credentialsId: 'fingerprint_jeevan', variable: 'TF_VAR_fingerprint'), file(credentialsId: 'api_key', variable: 'api_key_oci')]) {
            sh 'mkdir creds && echo ${api_key_oci} > creds/api_key.pem && export TF_VAR_private_key_path=creds/'
            sh 'env'
            sh 'terraform init examples/example-1'
            sh 'terraform plan -out examples/example-1/myplan examples/example-1'
          }
        }   
      }
      stage('Approval') {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
      stage('TF Apply') {
        container('terraform') {
          sh 'terraform apply -input=false examples/example-1/myplan'
        }
      }
    }
  }


