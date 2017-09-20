EXEC sp_execute_external_script
	@language = N'Python'
   ,@script = N'
from microsoftml import rx_featurize, categorical

# rx_featurize basically allows you to access data from the MicrosoftML transforms
# In this example well look at getting the output of the categorical transform
# Create the data
categorical_data = pandas.DataFrame(data=dict(places_visited=[
                "London", "Brunei", "London", "Paris", "Seria"]),
                dtype="category")

print(categorical_data)

# Invoke the categorical transform
categorized = rx_featurize(data=categorical_data,
                           ml_transforms=[categorical(cols=dict(xdatacat="places_visited"))])

# Now lets look at the data
print(categorized)
'