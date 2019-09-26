#!/usr/bin/env python
# coding: utf-8

# In[2]:


get_ipython().system('pip install psycopg2')
get_ipython().system('pip install psycopg2-binary')


# In[3]:


import matplotlib
from matplotlib import style
style.use('seaborn')
import matplotlib.pyplot as plt


# In[4]:


import pandas as pd


# In[5]:


import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, MetaData, Table, Column, ForeignKey
from sqlalchemy import create_engine, inspect


# In[6]:


#Connected to postgres database EmployeeSQL
user = "postgres"
password = "changeme"
host = "localhost"
port = "5432" 
db = "EmployeeSQL"
uri = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
uri


# In[7]:


# Declare a Base using `automap_base()`
Base=automap_base()


# In[8]:


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


# In[16]:


# Create a dataframe from two Joined classes
emp_salary_title_df=pd.DataFrame(same_emp_no, columns=['Employee Number','Salary', 'Title'])


# In[17]:


#Dropped Employee Number column from the dataframe
emp_salary_title2_df=emp_salary_title_df.drop('Employee Number', 1)


# In[18]:


emp_salary_title2_df.head()


# In[19]:


emp_salary_title2_df.columns


# In[20]:


#changed Salary to an integer type variable
emp_salary_title2_df['Salary']=emp_salary_title2_df['Salary'].astype(int)


# In[21]:


emp_salary_title2_df.dtypes


# In[22]:


#grouped dataframe by Title with Mean Salary 
title_salary_df=emp_salary_title2_df.groupby(["Title"])
title_salary_df=title_salary_df.mean()
title_salary_df.head()


# In[23]:


#Created a dataframe from groupby
title_salary_df=pd.DataFrame(title_salary_df)
title_salary_df


# In[26]:


#Created horizontal bar graph from data frame
title_salary_df.iloc[::-1].plot.bar(title="Current Mean Salary by Title")
plt.show()


# In[ ]:




