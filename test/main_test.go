package main_test 

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Ein mellomnivå-test som sjekkar at satt definisjon stemmer med faktisk definisjon.
// Utførast mens EC"-maskinene går
func TestEc2WebClusterEc2Status(t *testing.T) {
	t.Parallel()

	expectedEc2:= "t2.micro"
	expectedEc2List := []string{expectedEc2, expectedEc2, expectedEc2}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{

		// Gå til *.tf filene opp eit nivå
		TerraformDir: "../",


		// Me vil ha fargar! 
		NoColor: false,
	})

	// Ta ned etter testen
	defer terraform.Destroy(t, terraformOptions)

	// Sett opp med terraform init og terraform apply før test
	terraform.InitAndApply(t, terraformOptions)

	// Bruk terraform output for å hente ut instanse type
	actualEc2List := terraform.OutputList(t, terraformOptions, "ec2_instance_type")

	// Testen; sjekk om dei er like
	assert.Equal(t, expectedEc2List, actualEc2List)
}
