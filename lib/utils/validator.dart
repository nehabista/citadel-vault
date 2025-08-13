// matching various patterns for kinds of data

class Validator {
  Validator();

  String? firstName(String? value) {
    String pattern = r"^[a-zA-Z0-9][a-zA-Z0-9 ',.-]*$";
    if (value == null || value.isEmpty) {
      return 'Please enter your first name.';
    } else if (value.length < 2) {
      return 'First name must be at least 2 characters long.';
    } else if (value.length > 50) {
      return 'First name must be less than 50 characters.';
    } else if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid first name.';
    }
    return null;
  }

  String? lastName(String? value) {
    String pattern = r"^[a-zA-Z0-9][a-zA-Z0-9 ',.-]*$";
    if (value == null || value.isEmpty) {
      return 'Please enter your last name.';
    } else if (value.length < 2) {
      return 'Last name must be at least 2 characters long.';
    } else if (value.length > 50) {
      return 'Last name must be less than 50 characters.';
    } else if (!RegExp(pattern).hasMatch(value)) {
      return 'Please enter a valid last name.';
    }
    return null;
  }

  String? email(String? value) {
    String pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(pattern);
    if (value!.isEmpty) {
      return ("Email can't be empty.");
    } else if (!regex.hasMatch(value)) {
      return 'Invalid Email Address, Enter a valid email address.';
    } else {
      return null;
    }
  }

  String? password(String? value) {
    String pattern = r'^.{6,}$';
    RegExp regex = RegExp(pattern);
    if (value!.isEmpty) {
      return ("Password can't be empty.");
    }
    if (!regex.hasMatch(value)) {
      return 'Please, Enter a Valid Password(Min. 7 Characters.)';
    } else {
      return null;
    }
  }

  String? name(String? value) {
    String pattern = r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
    RegExp regex = RegExp(pattern);
    if (value!.isEmpty) {
      return ("Name can't be Empty");
    }
    if (!regex.hasMatch(value)) {
      return ("Enter Valid name(Min. 4 Character).");
    } else {
      return null;
    }
  }

  String? username(String? value, bool isUnique) {
    String pattern = r"^[a-zA-Z0-9_.]+(([',. -][a-zA-Z0-9 ])?[a-zA-Z0-9_]*)*$";
    RegExp regex = RegExp(pattern);
    if (value!.isEmpty) {
      return ("Username can't be Empty");
    }
    if (isUnique) {
      return ("Username already taken");
    }
    if (!regex.hasMatch(value)) {
      return ("Enter Valid Username (Min. 4 Character).");
    } else {
      return null;
    }
  }

  String? number(String? value) {
    String pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Please enter a valid number.';
    } else {
      return null;
    }
  }

  String? phoneNumber(String? value) {
    String pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return "Please enter a valid phone number.";
    } else {
      return null;
    }
  }

  String? amount(String? value) {
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Please enter a valid amount.';
    } else {
      return null;
    }
  }

  String? notEmpty(String? value) {
    if (value!.isEmpty) {
      return "The Field can't be empty";
    } else {
      return null;
    }
  }

  String? pronouns(String? value) {
    if (value != null && value.isNotEmpty) {
      String pattern = r"^[a-zA-Z0-9][a-zA-Z0-9 ',.-/]*$";
      if (value.length < 2) {
        return 'Pronouns must be at least 2 characters long.';
      } else if (value.length > 50) {
        return 'Pronouns must be less than 50 characters.';
      } else if (!RegExp(pattern).hasMatch(value)) {
        return 'Please enter valid pronouns.';
      }
    }
    return null;
  }

  String? bio(String? value) {
    if (value != null && value.isNotEmpty) {
      String pattern = r"^[a-zA-Z0-9][a-zA-Z0-9 ',.-]*$";
      if (value.length < 2) {
        return 'Bio must be at least 2 characters long.';
      } else if (value.length > 2000) {
        return 'Bio must be less than 2000 characters.';
      } else if (!RegExp(pattern).hasMatch(value)) {
        return 'Please enter a valid bio.';
      }
    }
    return null;
  }

  String? instagramUrl(String? value) {
    if (value != null && value.isNotEmpty) {
      String pattern = r"^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$";

      if (value.length < 2) {
        return 'Instagram url must be at least 2 characters long.';
      } else if (value.length > 2000) {
        return 'Instagram url must be less than 2000 characters.';
      } else if (!RegExp(pattern).hasMatch(value)) {
        return 'Please enter a valid Instagram url.';
      }
    }
    return null;
  }

  String? websiteUrl(String? value) {
    if (value != null && value.isNotEmpty) {
      String pattern = r"^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$";
      if (value.length < 2) {
        return 'Website url must be at least 2 characters long.';
      } else if (value.length > 1000) {
        return 'Website url must be less than 1000 characters.';
      } else if (!RegExp(pattern).hasMatch(value)) {
        return 'Please enter a valid website url.';
      }
    }
    return null;
  }
}
