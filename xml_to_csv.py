import requests
from datetime import datetime
import zipfile
import xml.etree.ElementTree as ET


def download_file(url, output_folder):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            zip_path = './instantane.zip'
            with open(zip_path, 'wb') as f:
                f.write(response.content)
                print('File saved successfully.')

            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(output_folder)
                
            print('File unzipped successfully.')
        else:
            print('Request status code: ' + response.status_code)
    except Exception as e:
        print(e)

def parse_xml(xml_file):
    try:
        tree = ET.parse('PrixCarburants_instantane.xml')
        root = tree.getroot()
        print('XML parsed successfully.')
        return root
    except Exception as e:
        print(e)

def write_csv(root):
    try:    
        dt_now = datetime.now()
        print('Writing csv ...')
        with open('instantane.csv', 'w') as f:
            f.write('id,record_timestamp,latitude,longitude,cp,pop,adresse,ville,horaires,services,gazole_maj,gazole_prix,sp95_maj,sp95_prix,e85_maj,e85_prix,gplc_maj,gplc_prix,e10_maj,e10_prix,sp98_maj,sp98_prix\n')

        for item in root.findall('pdv')[:3]:
            id                  = int(item.get('id')) if item.get('id') is not None else None
            record_timestamp    = dt_now
            latitude            = float(item.get('latitude')) if item.get('latitude') is not None else None
            longitude           = float(item.get('longitude')) if item.get('longitude') is not None else None
            cp                  = item.get('cp') if item.get('cp') is not None else None
            pop                 = item.get('pop') if item.get('pop') is not None else None
            adresse             = item.find('adresse').text if item.find('adresse') is not None else None
            ville               = item.find('ville').text if item.find('ville') is not None else None
            horaires            = item.get('horaires') if item.get('horaires') is not None else None
            services            = item.get('services') if item.get('services') is not None else None
            gazole_maj          = datetime.strptime(item.find("prix[@nom='Gazole']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='Gazole']") is not None else None
            gazole_prix         = float(item.find("prix[@nom='Gazole']").get('valeur')) if item.find("prix[@nom='Gazole']") is not None else None
            sp95_maj            = datetime.strptime(item.find("prix[@nom='SP95']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='SP95']") is not None else None
            sp95_prix           = float(item.find("prix[@nom='SP95']").get('valeur')) if item.find("prix[@nom='SP95']") is not None else None
            e85_maj             = datetime.strptime(item.find("prix[@nom='E85']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='E85']") is not None else None
            e85_prix            = float(item.find("prix[@nom='E85']").get('valeur')) if item.find("prix[@nom='E85']") is not None else None
            gplc_maj            = datetime.strptime(item.find("prix[@nom='GPLc']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='GPLc']") is not None else None
            gplc_prix           = float(item.find("prix[@nom='GPLc']").get('valeur')) if item.find("prix[@nom='GPLc']") is not None else None
            e10_maj             = datetime.strptime(item.find("prix[@nom='E10']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='E10']") is not None else None
            e10_prix            = float(item.find("prix[@nom='E10']").get('valeur')) if item.find("prix[@nom='E10']") is not None else None
            sp98_maj            = datetime.strptime(item.find("prix[@nom='SP98']").get('maj'), '%Y-%m-%d %H:%M:%S') if item.find("prix[@nom='SP98']") is not None else None
            sp98_prix           = float(item.find("prix[@nom='SP98']").get('valeur')) if item.find("prix[@nom='SP98']") is not None else None

            with open('instantane.csv', 'a') as f:
                f.write(str(id) + ',' + str(record_timestamp) + ',' + str(latitude) + ',' + str(longitude) + ',' + str(cp) + ',' + str(pop) + ',' + str(adresse) + ',' + str(ville) + ',' + str(horaires) + ',' + str(services) + ',' + str(gazole_maj) + ',' + str(gazole_prix) + ',' + str(sp95_maj) + ',' + str(sp95_prix) + ',' + str(e85_maj) + ',' + str(e85_prix) + ',' + str(gplc_maj) + ',' + str(gplc_prix) + ',' + str(e10_maj) + ',' + str(e10_prix) + ',' + str(sp98_maj) + ',' + str(sp98_prix) + '\n')
        
        print('CSV written successfully.')
        # close the file
        f.close()

    except Exception as e:
        print(e)

if __name__ == '__main__':

    url = 'https://donnees.roulez-eco.fr/opendata/instantane'
    output_folder = './'

    download_file(url, output_folder)
    root = parse_xml('PrixCarburants_instantane.xml')
    write_csv(root)