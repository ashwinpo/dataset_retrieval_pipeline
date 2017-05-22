import re

def getIsoEntity(query):
    entityList = query.split("AND")
    isoEntityList = []
    for item in entityList:
        if "AND" in item:
            continue
        elif "OR" in item:
            continue
        elif '\"' in item:
            continue
        else:
            isoEntityList.append(item)
    return isoEntityList

def textAnalyzer(text):
    text = re.findall(("\"(.*)\""),text)
    return text

def clauseAnalyzer(text,result):
    if "OR" in text:
        subText = text.split("OR")
        for sub in subText:
            result.append(clauseAnalyzer(sub,result))
    else:
        if "AND" in text:
            text = text.split("AND")
            text = [textAnalyzer(item) for item in text]
            text = [item for sublist in text for item in sublist]
        else:
            text = textAnalyzer(text)
        return " ".join(text)


def pubmed_query_analyzer(query):
    ## clean raw query
    query = re.sub('\[.*?\]','',query)
    isoEntityList = getIsoEntity(query)
    for isoEntity in isoEntityList:
        newIsoEntity = ' ("%s") '%isoEntity.strip()
        query = re.sub(isoEntity, newIsoEntity, query)

    clauseList = query.split(") AND (")
    ## extract entities and keep the structure
    result = []
    for clause in clauseList:
        clean_clause=[]
        if "AND" in clause or "OR" in clause:
            clauseAnalyzer(clause,clean_clause)
            result.append(set(clean_clause))
        else:
            clause = textAnalyzer(clause)
            clause = " ".join(clause)
            result.append(set([clause]))

    return(result)

    ## format json query
