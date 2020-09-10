package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsLogsConfig(t *testing.T) {
	t.Parallel()

	configName := fmt.Sprintf("aws-config-%s", strings.ToLower(random.UniqueId()))

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/config")
	// AWS only supports one configuration recorder per region.
	// Each test using aws-config will need to specify a different region.
	awsRegion := "us-east-2"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":             awsRegion,
			"test_name":          testName,
			"config_name":        configName,
			"force_destroy":      true,
			"config_logs_prefix": testName,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func TestTerraformAwsLogsConfigRootPrefix(t *testing.T) {
	t.Parallel()

	configName := fmt.Sprintf("aws-config-%s", strings.ToLower(random.UniqueId()))

	testName := fmt.Sprintf("terratest-aws-logs-%s", strings.ToLower(random.UniqueId()))
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/config")
	// AWS only supports one configuration recorder per region.
	// Each test using aws-config will need to specify a different region.
	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Vars: map[string]interface{}{
			"region":             awsRegion,
			"test_name":          testName,
			"config_name":        configName,
			"force_destroy":      true,
			"config_logs_prefix": "",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
