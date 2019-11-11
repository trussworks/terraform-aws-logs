package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsLogsCombined(t *testing.T) {
	// Note: do not run this test in t.Parallel() mode.

	expectedLogsBucket := fmt.Sprintf("terratest-aws-logs-combined-%s", strings.ToLower(random.UniqueId()))
	vpcName := fmt.Sprintf("terratest-vpc-combined-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]
	testRedshift := !testing.Short()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/combined/",
		Vars: map[string]interface{}{
			"region":        awsRegion,
			"vpc_azs":       vpcAzs,
			"logs_bucket":   expectedLogsBucket,
			"vpc_name":      vpcName,
			"test_redshift": testRedshift,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// Empty and delete logs_bucket before terraform destroy
	defer aws.DeleteS3Bucket(t, awsRegion, expectedLogsBucket)
	defer aws.EmptyS3Bucket(t, awsRegion, expectedLogsBucket)
	terraform.InitAndApply(t, terraformOptions)
}
