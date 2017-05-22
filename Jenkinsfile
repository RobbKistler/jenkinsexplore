#!/bin/groovy
node {
   stage('Build') {
        checkout scm
        sh('env')
        sh('make')

        if (env.BRANCH_NAME == 'master') 
           sh('echo This is master')
   }

   stage('Test') {
      // induce failure
      try {
        sh('Testing stage')
      } catch (err) {
        sh('echo in catch block')
      }
   }

   stage('Notify') {
      sh('echo Would send slack message here')
      echo("currentBuild.result: ${currentBuild.result}")
   }
}
