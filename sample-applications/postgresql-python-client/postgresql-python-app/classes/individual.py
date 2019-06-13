class Individual:
    def __str__(self):
     return f"Name: {self.name}, Address: {self.address}, Age: {self.age}, Height: {self.height}"

    def __init__(self, name=None, address=None, age=None, height=None):
        self.name = name
        self.address = address
        self.age = age
        self.height = height

