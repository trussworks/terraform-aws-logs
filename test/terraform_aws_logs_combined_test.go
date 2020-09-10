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

func TestTerraformAwsLogsCombined(t *testing.T) {
	// Note: do not run this test in t.Parallel() mode.
	configName := fmt.Sprintf("aws-config-%s", strings.ToLower(random.UniqueId()))
	expectedConfigLogsBucket := fmt.Sprintf("terratest-%s", configName)

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/combined")
	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	// AWS only supports one configuration recorder per region.
	// Each test using aws-config will need to specify a different region.
	awsRegion := "us-east-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]
	testRedshift := !testing.Short()

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":             awsRegion,
			"vpc_azs":            vpcAzs,
			"config_name":        configName,
			"config_logs_bucket": expectedConfigLogsBucket,
			"test_name":          testName,
			"test_redshift":      testRedshift,
			"force_destroy":      true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
