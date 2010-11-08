#ifndef PERSON_H_9QDZN2ZE
#define PERSON_H_9QDZN2ZE

#include <string>

class Person
{
public:
	Person (std::string initialName);
	virtual ~Person ();
	
	//Getters
	int getID();
	std::string getName();
	bool isAdmin();
	long getPWHash();
	std::string getEmail();
	
	//Setters
	void setName(std::string password, std::string newName);
	void setAdmin(Person settingAdmin, bool adminStatus);
	void resetPassword();
	void setPassword(std::string oldPassword, std::string newPassword);
	void setEmail(std::string password, std::string newEmail);
	
private:
	int id;
	std::string name;
	bool admin;
	long passwordHash;
	std::string email;
};

#endif /* end of include guard: PERSON_H_9QDZN2ZE */
