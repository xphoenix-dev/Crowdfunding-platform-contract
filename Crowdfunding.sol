// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdfundingPlatform {
    struct Project {
        address payable owner;
        string description;
        uint256 targetAmount;
        uint256 currentAmount;
        uint256 deadline;
        bool isCompleted;
        mapping(address => uint256) contributions;
    }

    uint256 public projectCount;
    mapping(uint256 => Project) public projects;

    event ProjectCreated(uint256 projectId, address owner, string description, uint256 targetAmount, uint256 deadline);
    event ContributionMade(uint256 projectId, address contributor, uint256 amount);
    event FundsWithdrawn(uint256 projectId, address owner, uint256 amount);

    function createProject(string calldata description, uint256 targetAmount, uint256 duration) external {
        require(targetAmount > 0, "Target amount must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");

        projectCount += 1;
        Project storage newProject = projects[projectCount];
        newProject.owner = payable(msg.sender);
        newProject.description = description;
        newProject.targetAmount = targetAmount;
        newProject.deadline = block.timestamp + duration;

        emit ProjectCreated(projectCount, msg.sender, description, targetAmount, newProject.deadline);
    }

    function contribute(uint256 projectId) external payable {
        Project storage project = projects[projectId];
        require(block.timestamp <= project.deadline, "Project funding period is over");
        require(msg.value > 0, "Contribution must be greater than zero");

        project.contributions[msg.sender] += msg.value;
        project.currentAmount += msg.value;

        emit ContributionMade(projectId, msg.sender, msg.value);
    }

    function withdrawFunds(uint256 projectId) external {
        Project storage project = projects[projectId];
        require(msg.sender == project.owner, "Only the project owner can withdraw funds");
        require(block.timestamp > project.deadline, "Project funding period is still active");
        require(project.currentAmount >= project.targetAmount, "Target amount not reached");
        require(!project.isCompleted, "Project is already completed");

        project.isCompleted = true;
        project.owner.transfer(project.currentAmount);

        emit FundsWithdrawn(projectId, project.owner, project.currentAmount);
    }

    function getProjectDetails(uint256 projectId) external view returns (
        address owner, 
        string memory description, 
        uint256 targetAmount, 
        uint256 currentAmount, 
        uint256 deadline, 
        bool isCompleted
    ) {
        Project storage project = projects[projectId];
        return (
            project.owner,
            project.description,
            project.targetAmount,
            project.currentAmount,
            project.deadline,
            project.isCompleted
        );
    }
}
