package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsLogsRedshift(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping test in short mode.")
	}

	t.Parallel()

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/redshift")
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":               awsRegion,
			"vpc_azs":              vpcAzs,
			"test_name":            testName,
			"force_destroy":        true,
			"redshift_logs_prefix": testName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsRedshiftRootPrefix(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping test in short mode.")
	}

	t.Parallel()

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/redshift")
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":               awsRegion,
			"vpc_azs":              vpcAzs,
			"test_name":            testName,
			"force_destroy":        true,
			"redshift_logs_prefix": "",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
