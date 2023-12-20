#
# config/crd/experimental/gateway.networking.k8s.io_gatewayclasses.yaml
#
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: https://github.com/kubernetes-sigs/gateway-api/pull/2466
    gateway.networking.k8s.io/bundle-version: v1.0.0
    gateway.networking.k8s.io/channel: experimental
  creationTimestamp: null
  name: gatewayclasses.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    categories:
      - gateway-api
    kind: GatewayClass
    listKind: GatewayClassList
    plural: gatewayclasses
    shortNames:
      - gc
    singular: gatewayclass
  scope: Cluster
  versions:
    - additionalPrinterColumns:
        - jsonPath: .spec.controllerName
          name: Controller
          type: string
        - jsonPath: .status.conditions[?(@.type=="Accepted")].status
          name: Accepted
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
        - jsonPath: .spec.description
          name: Description
          priority: 1
          type: string
      name: v1
      schema:
        openAPIV3Schema:
          description: "GatewayClass describes a class of Gateways available to the user for creating Gateway resources. \n It is recommended that this resource be used as a template for Gateways. This means that a Gateway is based on the state of the GatewayClass at the time it was created and changes to the GatewayClass or associated parameters are not propagated down to existing Gateways. This recommendation is intended to limit the blast radius of changes to GatewayClass or associated parameters. If implementations choose to propagate GatewayClass changes to existing Gateways, that MUST be clearly documented by the implementation. \n Whenever one or more Gateways are using a GatewayClass, implementations SHOULD add the `gateway-exists-finalizer.gateway.networking.k8s.io` finalizer on the associated GatewayClass. This ensures that a GatewayClass associated with a Gateway is not deleted while in use. \n GatewayClass is a Cluster level resource."
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of GatewayClass.
              properties:
                controllerName:
                  description: "ControllerName is the name of the controller that is managing Gateways of this class. The value of this field MUST be a domain prefixed path. \n Example: \"example.net/gateway-controller\". \n This field is not mutable and cannot be empty. \n Support: Core"
                  maxLength: 253
                  minLength: 1
                  pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                  type: string
                  x-kubernetes-validations:
                    - message: Value is immutable
                      rule: self == oldSelf
                description:
                  description: Description helps describe a GatewayClass with more details.
                  maxLength: 64
                  type: string
                parametersRef:
                  description: "ParametersRef is a reference to a resource that contains the configuration parameters corresponding to the GatewayClass. This is optional if the controller does not require any additional configuration. \n ParametersRef can reference a standard Kubernetes resource, i.e. ConfigMap, or an implementation-specific custom resource. The resource can be cluster-scoped or namespace-scoped. \n If the referent cannot be found, the GatewayClass's \"InvalidParameters\" status condition will be true. \n Support: Implementation-specific"
                  properties:
                    group:
                      description: Group is the group of the referent.
                      maxLength: 253
                      pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                      type: string
                    kind:
                      description: Kind is kind of the referent.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                      type: string
                    name:
                      description: Name is the name of the referent.
                      maxLength: 253
                      minLength: 1
                      type: string
                    namespace:
                      description: Namespace is the namespace of the referent. This field is required when referring to a Namespace-scoped resource and MUST be unset when referring to a Cluster-scoped resource.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                      type: string
                  required:
                    - group
                    - kind
                    - name
                  type: object
              required:
                - controllerName
              type: object
            status:
              default:
                conditions:
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Waiting
                    status: Unknown
                    type: Accepted
              description: "Status defines the current state of GatewayClass. \n Implementations MUST populate status on all GatewayClass resources which specify their controller name."
              properties:
                conditions:
                  default:
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Accepted
                  description: "Conditions is the current status from the controller for this GatewayClass. \n Controllers should prefer to publish conditions using values of GatewayClassConditionType for the type of each Condition."
                  items:
                    description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                    properties:
                      lastTransitionTime:
                        description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                        format: date-time
                        type: string
                      message:
                        description: message is a human readable message indicating details about the transition. This may be an empty string.
                        maxLength: 32768
                        type: string
                      observedGeneration:
                        description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                        format: int64
                        minimum: 0
                        type: integer
                      reason:
                        description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                        maxLength: 1024
                        minLength: 1
                        pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                        type: string
                      status:
                        description: status of the condition, one of True, False, Unknown.
                        enum:
                          - "True"
                          - "False"
                          - Unknown
                        type: string
                      type:
                        description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                        maxLength: 316
                        pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                        type: string
                    required:
                      - lastTransitionTime
                      - message
                      - reason
                      - status
                      - type
                    type: object
                  maxItems: 8
                  type: array
                  x-kubernetes-list-map-keys:
                    - type
                  x-kubernetes-list-type: map
                supportedFeatures:
                  description: "SupportedFeatures is the set of features the GatewayClass support. It MUST be sorted in ascending alphabetical order. "
                  items:
                    description: SupportedFeature is used to describe distinct features that are covered by conformance tests.
                    enum:
                      - Gateway
                      - GatewayPort8080
                      - GatewayStaticAddresses
                      - HTTPRoute
                      - HTTPRouteDestinationPortMatching
                      - HTTPRouteHostRewrite
                      - HTTPRouteMethodMatching
                      - HTTPRoutePathRedirect
                      - HTTPRoutePathRewrite
                      - HTTPRoutePortRedirect
                      - HTTPRouteQueryParamMatching
                      - HTTPRouteRequestMirror
                      - HTTPRouteRequestMultipleMirrors
                      - HTTPRouteResponseHeaderModification
                      - HTTPRouteSchemeRedirect
                      - Mesh
                      - ReferenceGrant
                      - TLSRoute
                    type: string
                  maxItems: 64
                  type: array
                  x-kubernetes-list-type: set
              type: object
          required:
            - spec
          type: object
      served: true
      storage: false
      subresources:
        status: {}
    - additionalPrinterColumns:
        - jsonPath: .spec.controllerName
          name: Controller
          type: string
        - jsonPath: .status.conditions[?(@.type=="Accepted")].status
          name: Accepted
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
        - jsonPath: .spec.description
          name: Description
          priority: 1
          type: string
      name: v1beta1
      schema:
        openAPIV3Schema:
          description: "GatewayClass describes a class of Gateways available to the user for creating Gateway resources. \n It is recommended that this resource be used as a template for Gateways. This means that a Gateway is based on the state of the GatewayClass at the time it was created and changes to the GatewayClass or associated parameters are not propagated down to existing Gateways. This recommendation is intended to limit the blast radius of changes to GatewayClass or associated parameters. If implementations choose to propagate GatewayClass changes to existing Gateways, that MUST be clearly documented by the implementation. \n Whenever one or more Gateways are using a GatewayClass, implementations SHOULD add the `gateway-exists-finalizer.gateway.networking.k8s.io` finalizer on the associated GatewayClass. This ensures that a GatewayClass associated with a Gateway is not deleted while in use. \n GatewayClass is a Cluster level resource."
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of GatewayClass.
              properties:
                controllerName:
                  description: "ControllerName is the name of the controller that is managing Gateways of this class. The value of this field MUST be a domain prefixed path. \n Example: \"example.net/gateway-controller\". \n This field is not mutable and cannot be empty. \n Support: Core"
                  maxLength: 253
                  minLength: 1
                  pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                  type: string
                  x-kubernetes-validations:
                    - message: Value is immutable
                      rule: self == oldSelf
                description:
                  description: Description helps describe a GatewayClass with more details.
                  maxLength: 64
                  type: string
                parametersRef:
                  description: "ParametersRef is a reference to a resource that contains the configuration parameters corresponding to the GatewayClass. This is optional if the controller does not require any additional configuration. \n ParametersRef can reference a standard Kubernetes resource, i.e. ConfigMap, or an implementation-specific custom resource. The resource can be cluster-scoped or namespace-scoped. \n If the referent cannot be found, the GatewayClass's \"InvalidParameters\" status condition will be true. \n Support: Implementation-specific"
                  properties:
                    group:
                      description: Group is the group of the referent.
                      maxLength: 253
                      pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                      type: string
                    kind:
                      description: Kind is kind of the referent.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                      type: string
                    name:
                      description: Name is the name of the referent.
                      maxLength: 253
                      minLength: 1
                      type: string
                    namespace:
                      description: Namespace is the namespace of the referent. This field is required when referring to a Namespace-scoped resource and MUST be unset when referring to a Cluster-scoped resource.
                      maxLength: 63
                      minLength: 1
                      pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                      type: string
                  required:
                    - group
                    - kind
                    - name
                  type: object
              required:
                - controllerName
              type: object
            status:
              default:
                conditions:
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Waiting
                    status: Unknown
                    type: Accepted
              description: "Status defines the current state of GatewayClass. \n Implementations MUST populate status on all GatewayClass resources which specify their controller name."
              properties:
                conditions:
                  default:
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Accepted
                  description: "Conditions is the current status from the controller for this GatewayClass. \n Controllers should prefer to publish conditions using values of GatewayClassConditionType for the type of each Condition."
                  items:
                    description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                    properties:
                      lastTransitionTime:
                        description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                        format: date-time
                        type: string
                      message:
                        description: message is a human readable message indicating details about the transition. This may be an empty string.
                        maxLength: 32768
                        type: string
                      observedGeneration:
                        description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                        format: int64
                        minimum: 0
                        type: integer
                      reason:
                        description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                        maxLength: 1024
                        minLength: 1
                        pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                        type: string
                      status:
                        description: status of the condition, one of True, False, Unknown.
                        enum:
                          - "True"
                          - "False"
                          - Unknown
                        type: string
                      type:
                        description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                        maxLength: 316
                        pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                        type: string
                    required:
                      - lastTransitionTime
                      - message
                      - reason
                      - status
                      - type
                    type: object
                  maxItems: 8
                  type: array
                  x-kubernetes-list-map-keys:
                    - type
                  x-kubernetes-list-type: map
                supportedFeatures:
                  description: "SupportedFeatures is the set of features the GatewayClass support. It MUST be sorted in ascending alphabetical order. "
                  items:
                    description: SupportedFeature is used to describe distinct features that are covered by conformance tests.
                    enum:
                      - Gateway
                      - GatewayPort8080
                      - GatewayStaticAddresses
                      - HTTPRoute
                      - HTTPRouteDestinationPortMatching
                      - HTTPRouteHostRewrite
                      - HTTPRouteMethodMatching
                      - HTTPRoutePathRedirect
                      - HTTPRoutePathRewrite
                      - HTTPRoutePortRedirect
                      - HTTPRouteQueryParamMatching
                      - HTTPRouteRequestMirror
                      - HTTPRouteRequestMultipleMirrors
                      - HTTPRouteResponseHeaderModification
                      - HTTPRouteSchemeRedirect
                      - Mesh
                      - ReferenceGrant
                      - TLSRoute
                    type: string
                  maxItems: 64
                  type: array
                  x-kubernetes-list-type: set
              type: object
          required:
            - spec
          type: object
      served: true
      storage: true
      subresources:
        status: {}
