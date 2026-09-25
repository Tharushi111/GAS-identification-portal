/*
    GSA Identification Portal - Applicant Side Database
    SQL Server / SSMS
    Clean schema script for supervisor review.

    Note:
    - This is a fresh-setup script. Run it on a SQL Server instance where
      GSAIdentificationDB does not already exist.
    - Application form validation that depends on UI conditions should also
      be enforced in the backend before moving to the next step/submitting.
*/

CREATE DATABASE GSAIdentificationDB;
GO

USE GSAIdentificationDB;
GO

CREATE TABLE ApplicantUsers (
    ApplicantUserId INT IDENTITY(1,1) PRIMARY KEY,

    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,

    Email NVARCHAR(255) NOT NULL UNIQUE,

    PasswordHash NVARCHAR(500) NOT NULL,

    PhoneNumber NVARCHAR(30),

    IsEmailVerified BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL
);
GO

CREATE TABLE PasswordResetTokens (
    PasswordResetTokenId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicantUserId INT NOT NULL,

    Token NVARCHAR(500) NOT NULL,

    ExpiresAt DATETIME2 NOT NULL,

    IsUsed BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_PasswordResetTokens_ApplicantUsers
        FOREIGN KEY (ApplicantUserId)
        REFERENCES ApplicantUsers(ApplicantUserId)
);
GO

CREATE TABLE ApplicantProfiles (
    ApplicantProfileId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicantUserId INT NOT NULL UNIQUE,

    -- Additional Profile Details
    JobTitle NVARCHAR(150) NULL,
    PreferredLanguage NVARCHAR(100) NULL,
    CompanyName NVARCHAR(255) NULL,
    Country NVARCHAR(100) NULL,
    City NVARCHAR(100) NULL,

    -- Organization Information
    LegalOrganizationName NVARCHAR(255) NULL,
    ApplicantType NVARCHAR(100) NULL,
    Territory NVARCHAR(150) NULL,
    IATAStatus NVARCHAR(100) NULL,

    ProfileCompleted BIT NOT NULL DEFAULT 0,
    ProfileCompletedAt DATETIME2 NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_ApplicantProfiles_ApplicantUsers
        FOREIGN KEY (ApplicantUserId)
        REFERENCES ApplicantUsers(ApplicantUserId)
);
GO

CREATE TABLE Applications (
    ApplicationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicantUserId INT NOT NULL,

    -- Generated application number, e.g. GSA-2026-0001.
    -- Nullable while a draft is being initialized.
    ApplicationReference NVARCHAR(50) NULL,

    ApplicationType NVARCHAR(20) NOT NULL,
    Territory NVARCHAR(150) NULL,

    Status NVARCHAR(50) NOT NULL DEFAULT 'Draft',

    CurrentStep INT NOT NULL DEFAULT 1,
    CompletionPercentage INT NOT NULL DEFAULT 0,

    SubmittedAt DATETIME2 NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_Applications_ApplicationType
        CHECK (ApplicationType IN ('Passenger', 'Cargo')),

    CONSTRAINT CK_Applications_Status
        CHECK (
            Status IN (
                'Draft',
                'Submitted',
                'Under Review',
                'Approved'
            )
        ),

    CONSTRAINT CK_Applications_CurrentStep
        CHECK (CurrentStep BETWEEN 1 AND 8),

    CONSTRAINT CK_Applications_CompletionPercentage
        CHECK (CompletionPercentage BETWEEN 0 AND 100),

    CONSTRAINT FK_Applications_ApplicantUsers
        FOREIGN KEY (ApplicantUserId)
        REFERENCES ApplicantUsers(ApplicantUserId)
);
GO

-- SQL Server UNIQUE constraints on nullable columns can restrict multiple NULLs.
-- This filtered unique index keeps non-NULL application references unique
-- while allowing multiple draft rows before a reference is assigned.
CREATE UNIQUE INDEX UX_Applications_ApplicationReference
ON Applications(ApplicationReference)
WHERE ApplicationReference IS NOT NULL;
GO

CREATE TABLE CompanyIdentification (
    CompanyIdentificationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    LegalOrganizationName NVARCHAR(255) NULL,

    DateOfIncorporation DATE NULL,

    HasDifferentTradeName BIT NOT NULL DEFAULT 0,

    TradeName NVARCHAR(255) NULL,

    HasDifferentContractSigningEntity BIT NOT NULL DEFAULT 0,

    ContractSigningEntityName NVARCHAR(255) NULL,

    SubsidiaryName NVARCHAR(255) NULL,

    FranchiseName NVARCHAR(255) NULL,

    BranchName NVARCHAR(255) NULL,

    OtherOperatingModel NVARCHAR(255) NULL,

    TradeRegistrationNumber NVARCHAR(150) NULL,

    OfficialTelephoneNumber NVARCHAR(50) NULL,

    MainOfficeAddress NVARCHAR(500) NULL,

    MainOfficeState NVARCHAR(150) NULL,

    MainOfficeCountry NVARCHAR(150) NULL,

    MainOfficePostalCode NVARCHAR(30) NULL,

    EmailAddress NVARCHAR(255) NULL,

    SecondaryEmailAddress NVARCHAR(255) NULL,

    RegisteredAddress NVARCHAR(500) NULL,

    RegisteredState NVARCHAR(150) NULL,

    RegisteredCountry NVARCHAR(150) NULL,

    RegisteredPostalCode NVARCHAR(30) NULL,

    PrincipalBusiness NVARCHAR(500) NULL,

    OtherBusiness NVARCHAR(500) NULL,

    BusinessRegistrationRequiredInCountry BIT NULL,

    BusinessRegistrationRequiredInTerritory BIT NULL,

    ApplyingUnderParentCompany BIT NOT NULL DEFAULT 0,

    ParentCompanyName NVARCHAR(255) NULL,

    ParentCompanyDateEstablished DATE NULL,

    ParentCompanyPlaceEstablished NVARCHAR(255) NULL,

    TravelIndustryExperienceTerritoryYears INT NULL,

    TravelIndustryExperienceOtherTerritoryYears INT NULL,

    AirCargoExperienceTerritoryYears INT NULL,

    AirCargoExperienceOtherTerritoryYears INT NULL,

    ParentCompanyExperienceYears INT NULL,

    IATAStatus NVARCHAR(20) NULL,

    WillEstablishWhollyOwnedSubsidiary BIT NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_CompanyIdentification_IATAStatus
        CHECK (
            IATAStatus IS NULL
            OR IATAStatus IN ('IATA', 'NON IATA')
        ),

    CONSTRAINT FK_CompanyIdentification_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE GeneralInformation (
    GeneralInformationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    SoleProprietorship BIT NOT NULL DEFAULT 0,

    Partnership BIT NOT NULL DEFAULT 0,

    LimitedLiabilityCompany BIT NOT NULL DEFAULT 0,

    OtherBusinessEntity BIT NOT NULL DEFAULT 0,

    OtherBusinessEntityDescription NVARCHAR(255) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_GeneralInformation_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE OwnershipStructure (
    OwnershipStructureId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    IsSoleProprietorship BIT NOT NULL DEFAULT 0,

    IsPartnership BIT NOT NULL DEFAULT 0,

    IsCorporation BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_OwnershipStructure_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE FinancialInformation (
    FinancialInformationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    RegisteredCapital DECIMAL(18,2) NULL,

    RegisteredCapitalCurrency NVARCHAR(3) NULL,

    PaidUpCapital DECIMAL(18,2) NULL,

    PaidUpCapitalCurrency NVARCHAR(3) NULL,

    MinimumPaidUpCapital DECIMAL(18,2) NULL,

    MinimumPaidUpCapitalCurrency NVARCHAR(3) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_FinancialInformation_RegisteredCapital
        CHECK (
            RegisteredCapital IS NULL
            OR RegisteredCapital >= 0
        ),

    CONSTRAINT CK_FinancialInformation_PaidUpCapital
        CHECK (
            PaidUpCapital IS NULL
            OR PaidUpCapital >= 0
        ),

    CONSTRAINT CK_FinancialInformation_MinimumPaidUpCapital
        CHECK (
            MinimumPaidUpCapital IS NULL
            OR MinimumPaidUpCapital >= 0
        ),

    CONSTRAINT FK_FinancialInformation_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE Shareholders (
    ShareholderId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL,

    Title NVARCHAR(20) NOT NULL,

    FirstName NVARCHAR(100) NOT NULL,

    LastName NVARCHAR(100) NOT NULL,

    AddressLine1 NVARCHAR(255) NOT NULL,

    AddressLine2 NVARCHAR(255) NULL,

    StateCity NVARCHAR(150) NULL,

    Country NVARCHAR(100) NULL,

    PostalCode NVARCHAR(30) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_Shareholders_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO


CREATE TABLE PremisesInformation (
    PremisesInformationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    CurrentOfficeAddress NVARCHAR(500) NULL,
    CurrentOfficeState NVARCHAR(150) NULL,
    CurrentOfficeCountry NVARCHAR(150) NULL,
    CurrentOfficePostalCode NVARCHAR(30) NULL,

    CurrentOfficeSurfaceArea DECIMAL(12,2) NULL,
    CurrentOfficeSurfaceAreaUnit NVARCHAR(20) NULL DEFAULT 'm²',

    CurrentContactTitle NVARCHAR(20) NULL,
    CurrentContactFirstName NVARCHAR(100) NULL,
    CurrentContactLastName NVARCHAR(100) NULL,
    CurrentContactDesignation NVARCHAR(150) NULL,

    CurrentContactLandPhone NVARCHAR(50) NULL,
    CurrentContactMobilePhone NVARCHAR(50) NULL,

    RepresentsOtherAirlineOffice BIT NOT NULL DEFAULT 0,

    -- Enabled only when RepresentsOtherAirlineOffice = 1
    OtherAirlineName NVARCHAR(255) NULL,
    OtherAirlineOfficeAddress NVARCHAR(500) NULL,
    OtherAirlineOfficeState NVARCHAR(150) NULL,
    OtherAirlineOfficeCountry NVARCHAR(150) NULL,
    OtherAirlineOfficePostalCode NVARCHAR(30) NULL,
    OtherAirlineOfficeSurfaceArea DECIMAL(12,2) NULL,
    OtherAirlineOfficeSurfaceAreaUnit NVARCHAR(20) NULL,

    OtherAirlineContactTitle NVARCHAR(20) NULL,
    OtherAirlineContactFirstName NVARCHAR(100) NULL,
    OtherAirlineContactLastName NVARCHAR(100) NULL,
    OtherAirlineContactDesignation NVARCHAR(150) NULL,
    OtherAirlineContactLandPhone NVARCHAR(50) NULL,
    OtherAirlineContactMobilePhone NVARCHAR(50) NULL,


    CentralBusinessArea NVARCHAR(255) NULL,

    AirportBusinessHub NVARCHAR(255) NULL,

    ProposedOfficeAddress NVARCHAR(500) NULL,
    ProposedOfficeState NVARCHAR(150) NULL,
    ProposedOfficeCountry NVARCHAR(150) NULL,
    ProposedOfficePostalCode NVARCHAR(30) NULL,

    ProposedOfficeSurfaceArea DECIMAL(12,2) NULL,
    ProposedOfficeSurfaceAreaUnit NVARCHAR(20) NULL DEFAULT 'm²',

    AdditionalOfficeLocations NVARCHAR(1000) NULL,

    ProposedContactTitle NVARCHAR(20) NULL,
    ProposedContactFirstName NVARCHAR(100) NULL,
    ProposedContactLastName NVARCHAR(100) NULL,
    ProposedContactDesignation NVARCHAR(150) NULL,

    ProposedContactLandPhone NVARCHAR(50) NULL,
    ProposedContactMobilePhone NVARCHAR(50) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_Premises_CurrentSurfaceArea
        CHECK (
            CurrentOfficeSurfaceArea IS NULL
            OR CurrentOfficeSurfaceArea >= 0
        ),

    CONSTRAINT CK_Premises_ProposedSurfaceArea
        CHECK (
            ProposedOfficeSurfaceArea IS NULL
            OR ProposedOfficeSurfaceArea >= 0
        ),

    CONSTRAINT CK_Premises_OtherAirlineSurfaceArea
        CHECK (
            OtherAirlineOfficeSurfaceArea IS NULL
            OR OtherAirlineOfficeSurfaceArea >= 0
        ),

    CONSTRAINT FK_PremisesInformation_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE BranchOffices (
    BranchOfficeId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL,

    Address NVARCHAR(500) NULL,

    State NVARCHAR(150) NULL,

    Country NVARCHAR(150) NULL,

    PostalCode NVARCHAR(30) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_BranchOffices_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE OrganizationRelatedPersons (
    RelatedPersonId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL,

    PersonCategory NVARCHAR(80) NOT NULL,

    Title NVARCHAR(20) NULL,

    FirstName NVARCHAR(100) NOT NULL,

    LastName NVARCHAR(100) NOT NULL,

    Designation NVARCHAR(150) NULL,

    ShareholdingPercentage DECIMAL(5,2) NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_OrganizationRelatedPersons_Category
        CHECK (
            PersonCategory IN (
                'DirectorOrPrincipalOfficer',
                'ParentSubsidiaryDirectorAlsoSriLankanDirector',
                'ParentSubsidiaryDirectorAlsoSriLankanEmployee',
                'CloseFamilyMemberOfSriLankanDirectorEmployee'
            )
        ),

    CONSTRAINT CK_OrganizationRelatedPersons_Shareholding
        CHECK (
            ShareholdingPercentage IS NULL
            OR ShareholdingPercentage BETWEEN 0 AND 100
        ),

    CONSTRAINT FK_OrganizationRelatedPersons_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE GSAStaffDetails (
    GSAStaffDetailId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL,

    /* Current employee */
    Title NVARCHAR(20) NULL,

    FirstName NVARCHAR(100) NOT NULL,

    LastName NVARCHAR(100) NOT NULL,

    PositionTitle NVARCHAR(150) NULL,

    DateOfEmployment DATE NULL,


    /* Previous employment */
    PreviousEmploymentYears INT NULL,

    PreviousEmploymentMonths INT NULL,

    PreviousPosition NVARCHAR(150) NULL,


    /* Previous employer */
    PreviousEmployerTitle NVARCHAR(20) NULL,

    PreviousEmployerFirstName NVARCHAR(100) NULL,

    PreviousEmployerLastName NVARCHAR(100) NULL,

    PreviousEmployerAddressLine1 NVARCHAR(255) NULL,

    PreviousEmployerAddressLine2 NVARCHAR(255) NULL,

    PreviousEmployerState NVARCHAR(150) NULL,

    PreviousEmployerCountry NVARCHAR(150) NULL,

    PreviousEmployerPostalCode NVARCHAR(30) NULL,


    /* Experience */
    QualificationsAndNetworkExperience NVARCHAR(MAX) NULL,

    TotalPassengerCargoExperienceYears INT NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT CK_GSAStaff_PreviousYears
        CHECK (
            PreviousEmploymentYears IS NULL
            OR PreviousEmploymentYears >= 0
        ),

    CONSTRAINT CK_GSAStaff_PreviousMonths
        CHECK (
            PreviousEmploymentMonths IS NULL
            OR PreviousEmploymentMonths BETWEEN 0 AND 11
        ),

    CONSTRAINT CK_GSAStaff_TotalExperience
        CHECK (
            TotalPassengerCargoExperienceYears IS NULL
            OR TotalPassengerCargoExperienceYears >= 0
        ),

    CONSTRAINT FK_GSAStaffDetails_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE OtherInformation (
    OtherInformationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    IsGSAForOtherAirline BIT NOT NULL DEFAULT 0,

    IntendsToRegisterAgreementWithGovernmentAuthority BIT NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_OtherInformation_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO

CREATE TABLE DocumentTypes (
    DocumentTypeId INT IDENTITY(1,1) PRIMARY KEY,

    DocumentTypeName NVARCHAR(200) NOT NULL UNIQUE,

    IsAlwaysRequired BIT NOT NULL DEFAULT 0,

    IsConditional BIT NOT NULL DEFAULT 0,

    RequiresDocumentYear BIT NOT NULL DEFAULT 0,

    MaxFiles INT NULL,

    Description NVARCHAR(500) NULL,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO DocumentTypes
(
    DocumentTypeName,
    IsAlwaysRequired,
    IsConditional,
    RequiresDocumentYear,
    MaxFiles,
    Description
)
VALUES

('Memorandum',
 1, 0, 0, NULL,
 'Memorandum of the organization'),

('Articles of Association',
 1, 0, 0, NULL,
 'Articles of association'),

('Certificate of Incorporation',
 1, 0, 0, NULL,
 'Certificate of incorporation'),

('Business Registration',
 1, 0, 0, NULL,
 'Business registration document'),

('Audited Financial Statement',
 1, 0, 1, 3,
 'Audited financial statements for the last three years'),

('Audit Report',
 1, 0, 0, NULL,
 'Report of the auditors'),

('Deed of Partnership',
 0, 1, 0, NULL,
 'Required where the applicant is a partnership'),

('Bank Reference',
 0, 0, 0, NULL,
 'Bank reference document'),

('Letter of Guarantee',
 0, 1, 0, NULL,
 'Required where the applicant relevant experience is less than five years'),

('Reference Letter - Airline',
 0, 0, 0, NULL,
 'Reference letter from another airline'),

('Reference Letter - Business Partner',
 0, 0, 0, NULL,
 'Reference letter from a business partner'),

('Operating Model Documentary Proof',
 0, 0, 0, NULL,
 'Documentary evidence supporting the selected operating model'),

('Other Relevant Document',
 0, 0, 0, NULL,
 'Any other document relevant to the application');
GO

CREATE TABLE ApplicationDocuments (
    ApplicationDocumentId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL,

    DocumentTypeId INT NOT NULL,

    -- Used mainly for audited financial statements
    DocumentYear INT NULL,

    OriginalFileName NVARCHAR(255) NOT NULL,

    StoredFileName NVARCHAR(255) NULL,

    FilePath NVARCHAR(1000) NOT NULL,

    FileExtension NVARCHAR(10) NOT NULL DEFAULT '.pdf',

    MimeType NVARCHAR(100) NOT NULL DEFAULT 'application/pdf',

    FileSizeBytes BIGINT NOT NULL,

    UploadedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT CK_ApplicationDocuments_FileSize
        CHECK (
            FileSizeBytes > 0
            AND FileSizeBytes <= 5242880
        ),

    CONSTRAINT CK_ApplicationDocuments_FileExtension
        CHECK (
            LOWER(FileExtension) = '.pdf'
        ),

    CONSTRAINT FK_ApplicationDocuments_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId),

    CONSTRAINT FK_ApplicationDocuments_DocumentTypes
        FOREIGN KEY (DocumentTypeId)
        REFERENCES DocumentTypes(DocumentTypeId)
);
GO

CREATE UNIQUE INDEX UX_ApplicationDocuments_TypeYear
ON ApplicationDocuments
(
    ApplicationId,
    DocumentTypeId,
    DocumentYear
)
WHERE DocumentYear IS NOT NULL
AND IsActive = 1;
GO

CREATE TABLE Declarations (
    DeclarationId INT IDENTITY(1,1) PRIMARY KEY,

    ApplicationId INT NOT NULL UNIQUE,

    -- Authorized Signatory Details
    Title NVARCHAR(20) NOT NULL,

    FirstName NVARCHAR(100) NOT NULL,

    LastName NVARCHAR(100) NOT NULL,

    Designation NVARCHAR(150) NOT NULL,

    ContactNumber NVARCHAR(50) NOT NULL,

    DeclarationDate DATE NOT NULL,

    Country NVARCHAR(100) NOT NULL,

    -- Signature File
    SignatureOriginalFileName NVARCHAR(255) NOT NULL,

    SignatureStoredFileName NVARCHAR(255) NULL,

    SignatureFilePath NVARCHAR(1000) NOT NULL,

    SignatureFileExtension NVARCHAR(20) NULL,

    SignatureMimeType NVARCHAR(100) NULL,

    SignatureFileSizeBytes BIGINT NULL,

    -- Review Confirmation Checkbox
    IsApplicationReviewedAndConfirmed BIT NOT NULL DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_Declarations_Applications
        FOREIGN KEY (ApplicationId)
        REFERENCES Applications(ApplicationId)
);
GO
