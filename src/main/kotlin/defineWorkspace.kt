package uk.gov.justice.hmpps.architecture

import com.structurizr.Workspace
import com.structurizr.model.*
import com.structurizr.view.ViewSet
import uk.gov.justice.hmpps.architecture.annotations.Tags

private val MODEL_ITEMS = listOf(
  AnalyticalPlatform,
  AssessRisksAndNeeds,
  AzureADTenantJusticeUK,
  BookVideoLink,
  CaseNotesToProbation,
  ComplexityOfNeed,
  CourtUsers,
  CourtRegister,
  CRCSystem,
  Curious,
  Delius,
  DigitalPrisonsNetwork,
  EPF,
  EQuiP,
  HMPPSAuth,
  HMPPSDomainEvents,
  IM,
  Interventions,
  InterventionTeams,
  Licences,
  MoJSignOn,
  NationalPrisonRadio,
  NDH,
  NID,
  NOMIS,
  OASys,
  ManagePOMCases,
  ManageASupervision,
  PolicyTeams,
  PrisonerMoney,
  PrepareCaseForSentence,
  PrisonerContentHub,
  PrisonToProbationUpdate,
  PrisonVisitsBooking,
  ProbationCaseSampler,
  ProbationPractitioners,
  ProbationTeamsService,
  Reporting,
  TierService,
  TokenVerificationApi,
  UserPreferenceApi,
  WhereaboutsApi,
  WMT
)

private fun defineModelItems(model: Model) {
  model.setImpliedRelationshipsStrategy(
    CreateImpliedRelationshipsUnlessSameRelationshipExistsStrategy()
  )

  AWS.defineDeploymentNodes(model)
  CloudPlatform.defineDeploymentNodes(model)
  Heroku.defineDeploymentNodes(model)
  Azure.defineDeploymentNodes(model)

  MODEL_ITEMS.forEach { it.defineModelEntities(model) }
  defineModelWithDeprecatedSyntax(model)
}

private fun changeUndefinedLocationsToInternal(model: Model) {
  model.softwareSystems
    .filter { it.location == Location.Unspecified }.forEach { it.setLocation(Location.Internal) }
  model.people
    .filter { it.location == Location.Unspecified }.forEach { it.setLocation(Location.Internal) }
}

private fun defineRelationships() {
  MODEL_ITEMS.forEach { it.defineRelationships() }
}

private fun defineViews(model: Model, views: ViewSet) {
  MODEL_ITEMS.forEach { it.defineViews(views) }
  defineGlobalViews(model, views)
}

fun defineWorkspace(): Workspace {
  val enterprise = Enterprise("HM Prison and Probation Service")
  val workspace = Workspace(enterprise.name, "Systems related to the custody and probation of offenders")
  workspace.id = 56937
  workspace.model.enterprise = enterprise

  defineModelItems(workspace.model)
  changeUndefinedLocationsToInternal(workspace.model)

  defineRelationships()
  defineViews(workspace.model, workspace.views)
  defineStyles(workspace.views.configuration.styles)

  workspace.model.softwareSystems.forEach { sys ->
    println(
      """---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: ${backstageId(sys)}
  title: "${sys.name}"
  description: "${sys.description}"
spec:
  owner: hmpps-undefined
      """.trimIndent()
    )
    sys.containers.forEach { c ->
      val lifecycle = if (c.hasTag(Tags.DEPRECATED.name)) "deprecated" else "production"
      println(
        """---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${backstageId(c)}
  title: "${c.name}"
  description: "${c.description}"
spec:
  type: service
  lifecycle: $lifecycle
  owner: hmpps-undefined
        """.trimIndent()
      )
      val containers = c.relationships.map { it.destination }.filterIsInstance<Container>()
      if (containers.isNotEmpty()) {
        println("  dependsOn:")
      }
      containers.forEach { c ->
        println("    - Component:${backstageId(c)}")
      }
    }
  }
  return workspace
}

fun backstageId(s: SoftwareSystem): String {
  return xbackstageId(s.name)
}

fun backstageId(c: Container): String {
  return xbackstageId("s" + c.softwareSystem.id + "_" + c.name)
}

private fun xbackstageId(name: String): String {
  return name.lowercase().replace(Regex("""[^a-z0-9]+"""), "-")
}
