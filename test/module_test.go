package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/terra_helper"

	"github.com/stretchr/testify/assert"
)

type RunSettings struct {
	t               *testing.T
	roleId          string
	secretId        string
	vaultSecretPath string
	terraformBinary string
	workingDir      string

	networkResourceGroupName string
	vnetName                 string
	subnetName               string
	costCenter               string
	environment              string
	owner                    string
	technicalContact         string
	shortRegion              string

	// azdoRepoName string
	azdoBuildId string

	azClientId       string
	azClientSecret   string
	azTenantId       string
	azSubscriptionId string

	envMap map[string]string
}

var resource_group_name = "diehlabs-test-" + getUniqueId() + "-rg"

func (r *RunSettings) setDefaults() {
	r.vaultSecretPath = "diehlabs/data/terraform/nonprod/azure/spn-name"
	r.azdoBuildId = getUniqueId()

	r.envMap = map[string]string{
		"ARM_CLIENT_ID":         "client_id",
		"ARM_CLIENT_SECRET":     "client_secret",
		"ARM_TENANT_ID":         "tenant_id",
		"ARM_SUBSCRIPTION_ID":   "subscription_id",
		"AZURE_CLIENT_ID":       "client_id",
		"AZURE_CLIENT_SECRET":   "client_secret",
		"AZURE_TENANT_ID":       "tenant_id",
		"AZURE_SUBSCRIPTION_ID": "subscription_id",
	}

	if r.t == nil {
		panic("No Terratest module provided")
	}

	r.workingDir = "../examples/build"
	if tfdir := os.Getenv("TERRATEST_WORKING_DIR"); tfdir != "" {
		r.workingDir = tfdir
	}

	r.terraformBinary = "/usr/local/bin/terraform"
	if tfcp := os.Getenv("AGENT_TEMPDIRECTORY"); tfcp != "" {
		r.terraformBinary = tfcp + "/terraform"
	}

	if role_id := os.Getenv("VAULT_APPROLE_ID"); role_id != "" {
		r.roleId = role_id
	}

	if wrapped_token := os.Getenv("VAULT_WRAPPED_TOKEN"); wrapped_token != "" {
		r.secretId = wrapped_token
	}

	// get secrets - GetSecretWithAppRole injects variables in to the environment see azure credentials
	spn := terra_helper.NewSecret(r.roleId, r.secretId, r.vaultSecretPath)
	envData := spn.MapData(r.envMap)
	spn.SetEnv(envData)
	// for key, value := range envData {
	// 	os.Setenv(key, value)
	// 	fmt.Println("Key:", key, "=>", "Value:", value)
	// }

	if azClientId := os.Getenv("AZURE_CLIENT_ID"); azClientId != "" {
		r.azClientId = azClientId
	}

	if azClientSecret := os.Getenv("AZURE_CLIENT_SECRET"); azClientSecret != "" {
		r.azClientSecret = azClientSecret
	}

	if azTenantId := os.Getenv("AZURE_TENANT_ID"); azTenantId != "" {
		r.azTenantId = azTenantId
	}

	if azSubscriptionId := os.Getenv("AZURE_SUBSCRIPTION_ID"); azSubscriptionId != "" {
		r.azSubscriptionId = azSubscriptionId
	}
}

func TestTerraformModule(t *testing.T) {
	t.Parallel()
	r := RunSettings{t: t}
	r.setDefaults()

	r.networkResourceGroupName = "Networking-DevTest-RG"
	r.vnetName = "hub-devtest-vnet"
	r.subnetName = "westus-test-subnet-terratest"
	r.costCenter = "001245"
	r.environment = "test"
	r.owner = "diehl"
	r.technicalContact = "devops@diehlabs.com"
	r.shortRegion = "wus"

	fmt.Println("azdo build id is: ", r.azdoBuildId)

	terraformVars := map[string]interface{}{
		"unique_id":                   r.azdoBuildId,
		"network_resource_group_name": "Networking-DevTest-RG",
		"vnet_name":                   "hub-devtest-vnet",
		"subnet_name":                 "westus-test-subnet-terratest",
		"product":                     r.azdoBuildId,
		"environment":                 "test",
		"resource_group_location":     "westus",
		"resource_group_name":         resource_group_name,
		"tags_extra": map[string]string{
			"created_by": "terratest",
			"unique_id":  r.azdoBuildId,
		},
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    r.workingDir,
		TerraformBinary: r.terraformBinary,
		Vars:            terraformVars,
	})

	test_structure.SaveTerraformOptions(t, r.workingDir, terraformOptions)

	// Destroy the infra after testing is finished
	defer test_structure.RunTestStage(t, "terraform_destroy", func() {
		terraformDestroy(t, r.workingDir)
	})

	// Deploy using Terraform
	test_structure.RunTestStage(t, "terraform_deploy", func() {
		deployUsingTerraform(t, r.workingDir)
	})

	test_structure.RunTestStage(t, "kv_test", func() {

		kv_test(t, r.workingDir)
	})
}

func deployUsingTerraform(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.InitAndApply(t, terraformOptions)
}

func terraformDestroy(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	terraform.Destroy(t, terraformOptions)
	test_structure.CleanupTestDataFolder(t, workingDir)
}

func kv_test(t *testing.T, workingDir string) {
	r := RunSettings{t: t}

	fmt.Print("befor assignment, sub id is: ", r.azSubscriptionId)
	r.azSubscriptionId = os.Getenv("AZURE_SUBSCRIPTION_ID")
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	// expectedSecretName := terraform.Output(t, terraformOptions, "my_secret_name")
	// secretValue := terraform.Output(t, terraformOptions, "my_secret_value")
	keyVaultName := terraform.Output(t, terraformOptions, "key_vault_name")
	kv_rg_name := terraform.Output(t, terraformOptions, "key_vault_resource_group")

	expectedKeyVaultName := resource_group_name + "-kv"
	fmt.Print("kv name is; ", expectedKeyVaultName)
	fmt.Print("subsription id is; ", r.azSubscriptionId)
	//assert.Equal(t, expectedSecretName, "secret-sauce")
	//assert.Equal(t, keyVaultName, expectedKeyVaultName)
	//assert.NotEmpty(t, secretValue)

	keyVault := azure.GetKeyVault(t, kv_rg_name, keyVaultName, r.azSubscriptionId)
	assert.Equal(t, keyVaultName, *keyVault.Name)

	//secretExists := azure.KeyVaultSecretExists(t, keyVaultName, expectedSecretName)
	//assert.True(t, secretExists, "kv-secret does not exist")
}

func getUniqueId() string {
	// if env var BUILD_BUILDID is not empty return the value
	localId := os.Getenv("BUILD_BUILDID")

	if localId != "" {
		return localId
	} else {
		return strings.ToLower(random.UniqueId())
	}
}
