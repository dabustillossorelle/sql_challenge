Brief Summary

The salary information for this office was a bit odd.  It appears Senior staff and staff made almost the same mean salary.  



--Table Creation
CREATE TABLE departments (
    "dept_no" VARCHAR   NOT NULL,
    "dept_name" VARCHAR(100)   NOT NULL,
    CONSTRAINT "pk_departments" PRIMARY KEY (
        "dept_no"
     )
);

CREATE TABLE employees (
    "emp_no" INTEGER   NOT NULL,
    "birth_date" DATE   NOT NULL,
    "first_name" VARCHAR(100)   NOT NULL,
    "last_name" VARCHAR(100)   NOT NULL,
    "gender" VARCHAR(10)   NOT NULL,
    "hire_date" DATE   NOT NULL,
	CONSTRAINT "pk_employees" PRIMARY KEY (
        "emp_no"
     )
 );

CREATE TABLE dept_emp (
    "emp_no" INTEGER   NOT NULL,
    "dept_no" VARCHAR   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
);

CREATE TABLE dept_manager (
    "dept_no" VARCHAR   NOT NULL,
    "emp_no" INTEGER   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
    CONSTRAINT "pk_dept_manager" PRIMARY KEY (
        "emp_no"
     )
);

CREATE TABLE salaries (
    "emp_no" INTEGER   NOT NULL,
    "salary" VARCHAR   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
);

CREATE TABLE titles (
    "emp_no" INTEGER   NOT NULL,
    "title" VARCHAR   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
);

--Created Constraints- Foreign Keys
ALTER TABLE dept_emp ADD CONSTRAINT "fk_dept_emp_emp_no" FOREIGN KEY("emp_no")
REFERENCES employees ("emp_no");

ALTER TABLE dept_emp ADD CONSTRAINT "fk_dept_emp_dept_no" FOREIGN KEY("dept_no")
REFERENCES departments ("dept_no");

ALTER TABLE dept_manager ADD CONSTRAINT "fk_dept_manager_emp_no" FOREIGN KEY("emp_no")
REFERENCES employees ("emp_no");

ALTER TABLE salaries ADD CONSTRAINT "fk_salaries_emp_no" FOREIGN KEY("emp_no")
REFERENCES employees ("emp_no");

ALTER TABLE titles ADD CONSTRAINT "fk_titles_emp_no" FOREIGN KEY("emp_no")
REFERENCES employees ("emp_no");

SELECT * FROM employees;

--List the following details of each employee: employee number, last name, first name, gender, and salary.
SELECT employees.emp_no, employees.last_name, employees.first_name, employees.gender, salaries.salary
FROM salaries INNER JOIN employees ON employees.emp_no=salaries.emp_no;

--List employees who were hired in 1986.
SELECT * FROM employees WHERE hire_date BETWEEN '1985-12-31' AND '1987-01-01';

--List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name, and start and end employment dates.
SELECT employees.last_name, employees.first_name, dept_manager.dept_no, dept_manager.emp_no, dept_manager.from_date, dept_manager.to_date, departments.dept_name
FROM dept_manager INNER JOIN employees ON employees.emp_no=dept_manager.emp_no INNER JOIN departments on dept_manager.dept_no=departments.dept_no;

--List the department of each employee with the following information: employee number, last name, first name, and department name.
SELECT dept_emp.emp_no, employees.last_name, employees.first_name, departments.dept_name
FROM dept_emp INNER JOIN employees ON employees.emp_no= dept_emp.emp_no INNER JOIN departments on dept_emp.dept_no=departments.dept_no;

--List all employees whose first name is "Hercules" and last names begin with "B."
SELECT * FROM employees WHERE first_name = 'Hercules' AND last_name LIKE 'B%';

--List all employees in the Sales department, including their employee number, last name, first name, and department name.
SELECT dept_emp.emp_no, employees.last_name, employees.first_name, departments.dept_name
FROM dept_emp INNER JOIN employees ON employees.emp_no=dept_emp.emp_no INNER JOIN departments on dept_emp.dept_no= departments.dept_no WHERE departments.dept_name = 'Sales';

--List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.
SELECT dept_emp.emp_no, employees.last_name, employees.first_name, departments.dept_name
FROM dept_emp INNER JOIN employees ON employees.emp_no=dept_emp.emp_no INNER JOIN departments on dept_emp.dept_no= departments.dept_no WHERE departments.dept_name = 'Sales' OR departments.dept_name = 'Development';

--In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.
SELECT last_name, COUNT(last_name) AS "Last_Name_Count" FROM employees GROUP BY last_name ORDER BY "Last_Name_Count" DESC;

--Bonus - I created a new table since titles had duplicate employees and I felt that having current salary information by Title would be most helpful.  Including past salary data would skew the mean.  
CREATE TABLE titles_current AS
  SELECT * FROM titles WHERE to_date = '9999-01-01';


  Jupyter Notebook 

  #!/usr/bin/env python
# coding: utf-8

# In[1]:


get_ipython().system('pip install psycopg2')
get_ipython().system('pip install psycopg2-binary')


# In[2]:


import matplotlib
from matplotlib import style
style.use('seaborn')
import matplotlib.pyplot as plt


# In[3]:


import pandas as pd


# In[4]:


import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, MetaData, Table, Column, ForeignKey
from sqlalchemy import create_engine, inspect


# In[5]:


#Connected to postgres database EmployeeSQL
user = "postgres"
password = "changeme"
host = "localhost"
port = "5432" 
db = "EmployeeSQL"
uri = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
uri


# In[6]:


# Declare a Base using `automap_base()`
Base=automap_base()


# In[7]:


# Create engine using the uri
engine = create_engine(uri)


# In[9]:


#Inspect database
inspector = inspect(engine)
inspector.get_table_names()


# In[10]:


columns = inspector.get_columns('salaries')
for c in columns:
    print(c['name'], c["type"])


# In[11]:


# Use the Base class to reflect the database tables
Base.prepare(engine, reflect=True)


# In[12]:


# Print all of the classes mapped to the Base
Base.classes.keys()


# In[13]:


# Assign the classes to a variables
Departments=Base.classes.departments
Employees=Base.classes.employees
Dept_Manager=Base.classes.dept_manager
Salaries=Base.classes.salaries
Titles_Current=Base.classes.titles_current


# In[14]:


# Create a session
session = Session(engine)


# In[15]:


#Join Salaries with Titles_Current 
salary_title=[Salaries.emp_no, Salaries.salary, Titles_Current.title]
same_emp_no=session.query(*salary_title).filter(Salaries.emp_no==Titles_Current.emp_no).all()
same_emp_no


# In[17]:


# Create a dataframe from two Joined classes
emp_salary_title_df=pd.DataFrame(same_emp_no, columns=['Employee Number','Salary', 'Title'])


# In[19]:


#Dropped Employee Number column from the dataframe
emp_salary_title2_df=emp_salary_title_df.drop('Employee Number', 1)


# In[20]:


emp_salary_title2_df.head()


# In[26]:


emp_salary_title2_df.columns


# In[29]:


#changed Salary to an integer type variable
emp_salary_title2_df['Salary']=emp_salary_title2_df['Salary'].astype(int)


# In[30]:


emp_salary_title2_df.dtypes


# In[31]:


#grouped dataframe by Title with Mean Salary 
title_salary_df=emp_salary_title2_df.groupby(["Title"])
title_salary_df=title_salary_df.mean()
title_salary_df.head()


# In[54]:


#Created a dataframe from groupby
title_salary_df=pd.DataFrame(title_salary_df)
title_salary_df


# In[53]:


#Created horizontal bar graph from data frame
title_salary_df.iloc[::-1].plot.barh(title="Current Mean Salary by Title")
plt.tight_layout()
plt.show()
