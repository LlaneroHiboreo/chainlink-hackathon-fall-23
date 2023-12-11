## Consumer Contracts
Solution1 -> 0xEA191e44b4576A37Db103f413C27DF5419956B0d
Solution2 -> 0xA676080452DD28adEcCbcfB582803DFE96f93Ec1

## Inspiration
The evolution of smart cities and blockchain technology has given rise to a new era in citizen health management, where security, transparency, and efficiency converge to create a robust ecosystem. Blockchain, as a decentralized and secure ledger, plays a pivotal role in safeguarding sensitive health data, fostering trust, and unlocking the full potential of interconnected smart city infrastructure. The integration of IoT devices in cities generates a wealth of real-time health data. Citizens can have confidence that their sensitive health information remains confidential and unaltered via blockchain integration empowering citizens to actively participate in their healthcare management, contributing to a more patient-centric approach. Furthermore, cloud infrastructures play an important role in the mentioned integration in the following contexts: 
- **Storage and Scalability** of vast amounts of data from wearables, sensors, and other devices
- **Integration and Interoperability** of heterogenous data  sources
- **Accessibility and Availability**

## What it does
Two related solutions are provided. 
Firstly, a user can generate a score calculated from different variables. Some variables come from city humidity,  temperature and UV rays. Other variables come from user data such BMI, calories burned and steps walked. Finally the score is is computed as a weighted sum of different the different variables/factors. The calculated scores are associated to each user. This may be used for insurances to decide wether coverage is applied or amount of tokens that can be spend on health providers.

The second solution tries to manage the access to the users health records. Users or patients are able to upload to the blockchain a snippet of their records and allow or decline the access of foreign users to their personal information.  Precisely, what is being uploaded and access controlled is a url link to their records. Users that want to access patient information have to pay fees imposed by the patients.

## How we built it
This project uses **Tencent Cloud** services to store, manage and query the information. 

Three Tencent MySql tables are created:
- PatientDataTable host information about the location of the patient records
- UserDataIoTTable hosts information from the generated data of user such BMI, calories, heart rate...
- SmartCityTable hosts information about generated data from sensors located in a city.

The three tables are related between them. PatientDataTable is linked with UserDataIoTTable via UserId (PK) and UserDataIoTTable is linked to SmartCityTable via CityID (Pk).

Once the database is setup, a Tencent Serverless Cloud Function (SCF) written in python is created in order to query the tables and return the desired information via an Api Call. Service Tencent ApiGateway is implemented upon  SCF to provide a layer of security and manageability. 

Finally, two smart contracts contracts are created representing each solution mentioned before. They both use Chainlink functions to connect via the DON to Tencent cloud SCF and obtain the desired information.

## Challenges we ran into
- Get to know Tencent Cloud
- Find Solidity and Chainlink functions use cases related to health management

## Accomplishments that we're proud of
- Gained enough experience to be able to set up a basic cloud infrastructure
- Merge topics such as health, cloud and blockchain into a single solution

## What we learned
- Tencent cloud services
- Deeper understanding of Chainlink funcitons

## What's next for TencentLink4Health
- Restrict and secure cloud services, rights now are pretty open for demonstration purposes
- Create an actual machine learning model, host it in the cloud and make predictions managing the results in the blockchain.
- Refactor solidity code and make it more secure
