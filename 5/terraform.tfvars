environment                 = "development"
location                    = "centralus"
solution_subnets  =  {
        AGSubnet        = "10.1.0.0/24"
        MgtSubnet       = "10.2.0.0/24"
        WebSubnet       = "10.3.0.0/24"
        BusiSubnet      = "10.4.0.0/24"
        DataSubnet      = "10.5.0.0/24"
        ADSubnet        = "10.6.0.0/24"
}
domain_name_label       = "terraformlearningsteveco"
resource_prefix         = "tfm"