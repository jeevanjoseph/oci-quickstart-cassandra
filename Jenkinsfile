
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
      envVar(key:'TF_VAR_compartment_ocid', value:'ocid1.compartment.oc1..aaaaaaaa4vxl6yyvfcumwutejntiu3tzcwacbpgdqndh3kct5i65ahvz7oma'),
      envVar(key:'TF_VAR_private_key_path', value:'./creds/api_key.pem')
      envVar(key:'TF_VAR_ssh_authorized_keys', value:'./creds/ssh_key.pub')
      envVar(key:'TF_VAR_ssh_private_key', value:'./creds/ssh_key.private')
      envVar(key:'TF_VAR_vcn_cidr', value:'192.168.0.0/24')
      envVar(key:'TF_VAR_subnet_ocids', value:'ocid1.subnet.oc1.phx.aaaaaaaan5tjgejifuxu2o5pm4vk4ywdvhujrhigdbhfkx6gtgrya3tg3yya')

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
          withCredentials([string(credentialsId: 'tenancy_ocid', variable: 'TF_VAR_tenancy_ocid'), string(credentialsId: 'user_ocid_jeevan', variable: 'TF_VAR_user_ocid'), string(credentialsId: 'fingerprint_jeevan', variable: 'TF_VAR_fingerprint'), file(credentialsId: 'api_key', variable: 'api_key_oci'), file(credentialsId: 'public_ssh_key', variable: 'public_ssh_key'), file(credentialsId: 'private_ssh_key', variable: 'private_ssh_key')]) {
            sh 'mkdir creds && echo ${api_key_oci} > creds/api_key.pem && chmod 700 creds/api_key.pem'
            sh 'echo ${public_ssh_key} > creds/ssh_key.pub && chmod 700 creds/ssh_key.pub'
            sh 'echo ${private_ssh_key} > creds/ssh_key.private && chmod 700 creds/ssh_key.private'
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


