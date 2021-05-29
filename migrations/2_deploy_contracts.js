let SetGrade = artifacts.require('SetGrade')
let User = artifacts.require('User')
let Certificate = artifacts.require('Certificate')

module.exports = async function (deployer) {
  await deployer.deploy(SetGrade);
  await deployer.deploy(User);
  await deployer.link(SetGrade, Certificate);
  await deployer.deploy(Certificate, User.address);
}
