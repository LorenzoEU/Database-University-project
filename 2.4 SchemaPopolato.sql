CREATE SCHEMA OrtiScolastici;

SET search_path TO OrtiScolastici;

SET datestyle TO "DMY";
/*Definizione Schema Relazionale */
CREATE TABLE Finanziamento
(
	Progetto VARCHAR(60) NOT NULL,
	Tipo VARCHAR(30) NOT NULL,
	PRIMARY KEY (Progetto)
);
CREATE TABLE Scuola 
(  
	CodMecc CHAR(10) NOT NULL,
    NomeScuola VARCHAR(30) NOT NULL,
    Provincia VARCHAR(30) NOT NULL,
	TipoScuola   VARCHAR(20) NOT NULL, 
    Progetto VARCHAR(60) references Finanziamento(Progetto) ON UPDATE CASCADE ON DELETE SET NULL,
    PRIMARY KEY (CodMecc)
);
CREATE TABLE Persona (
    Email VARCHAR(319) PRIMARY KEY,
    NomePersona VARCHAR(30) NOT NULL,
    Cognome VARCHAR(30) NOT NULL,
    Ruolo VARCHAR(30),
    Telefono VARCHAR(30),
    CodMecc CHAR(10),
    ReferenteScuola BOOLEAN,
    CONSTRAINT FK_Scuola_Persona FOREIGN KEY (CodMecc) REFERENCES Scuola(CodMecc)  ON UPDATE CASCADE ON DELETE NO ACTION
);
CREATE TABLE Classe
(
	Classe   VARCHAR(20),
    CodMecc CHAR(10) REFERENCES Scuola(CodMecc) ON UPDATE CASCADE ON DELETE CASCADE,
    Ordine   VARCHAR(40) NOT NULL, 
	Rappresentante  VARCHAR(319) REFERENCES Persona(email) ON UPDATE CASCADE ON DELETE NO ACTION,
    PRIMARY KEY (Classe,CodMecc)
);
CREATE TABLE Orto 
(
    NomeOrto VARCHAR(30) NOT NULL,
    CodMecc CHAR(10) NOT NULL,
    CoordNord DOUBLE PRECISION NOT NULL,
	CoordSud DOUBLE PRECISION NOT NULL,
    Superficie DOUBLE PRECISION NOT NULL CHECK(Superficie>0),
    TipoOrto VARCHAR(30) NOT NULL,
    ContestoAdatto BOOLEAN NOT NULL,
    PRIMARY KEY (NomeOrto, CodMecc),
    CONSTRAINT FK_Scuola_Orto 
		FOREIGN KEY (CodMecc) REFERENCES Scuola(CodMecc) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT check_CoordNord  CHECK(CoordNord>=-90 AND CoordNord<=90),
	CONSTRAINT check_CoordSud CHECK(CoordSud>=-180 AND CoordSud<=180)
);
CREATE TABLE Gruppo
(
	IdGruppo VARCHAR(30) NOT NULL PRIMARY KEY,
	NomeOrto VARCHAR(30),
	CodMecc CHAR(10),
	Scopo VARCHAR(30) NOT NULL CHECK (Scopo in ('Fitobotanica','Biomonitoraggio')),
	GruppoControllo VARCHAR(30) references Gruppo(IdGruppo) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY (NomeOrto,CodMecc) references Orto(NomeOrto,CodMecc) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT check_sintassi_IdGruppo CHECK (IdGruppo ~ '^G\d+$')
);
CREATE TABLE Specie
(
    NomeScientifico VARCHAR(60) NOT NULL,
    NomeComune VARCHAR(30) NOT NULL,
    Attività VARCHAR(30) NOT NULL,
    Terreno VARCHAR(30) NOT NULL,
	CHECK (Terreno in ('Vaso','Suolo')),
	CHECK(Attività in ('Biomonitoraggio','Fitobotanica')),
    PRIMARY KEY (NomeScientifico)
);
CREATE TABLE Strumento
(
	IdSensore   VARCHAR(30) PRIMARY KEY ,
    TipoStrumento VARCHAR(30) CHECK (TipoStrumento IN ('Arduino','Sensore')),
    Modello     VARCHAR(30) NOT NULL ,
	NomeOrto   VARCHAR(30),
    CodMecc  CHAR(10),
	CONSTRAINT check_sintassi_IdSensore CHECK (IdSensore ~ '^S\d+$'),
    FOREIGN KEY (NomeOrto,CodMecc) REFERENCES Orto ON UPDATE CASCADE ON DELETE SET NULL
);
CREATE TABLE Pianta 
(
  	IdReplica VARCHAR(20) PRIMARY KEY,
	Data DATE NOT NULL,
    Esposizione VARCHAR(20) NOT NULL check(Esposizione in('Sole','Ombra','Mezzombra','Sole-Mezzombra')),
	Gruppo VARCHAR(30) NOT NULL,
    NomeScientifico VARCHAR(60) NOT NULL,
	Strumento VARCHAR(30),
    CONSTRAINT FK_Gruppo_Pianta FOREIGN KEY (Gruppo) REFERENCES Gruppo(IdGruppo) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT FK_Specie_Pianta FOREIGN KEY (NomeScientifico) REFERENCES Specie(NomeScientifico) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT FK_Strumento_Pianta FOREIGN KEY (Strumento) REFERENCES Strumento(IdSensore) ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT check_sintassi_IdReplica CHECK (IdReplica ~ '^P\d+$')
);
CREATE TABLE Rilevazione
( 
	CodRilevazione VARCHAR(30) PRIMARY KEY,
	DataOraRilevazione DATE NOT NULL,
	RilevatoreP VARCHAR(30) REFERENCES Persona ON UPDATE CASCADE ON DELETE NO ACTION,
	RilevatoreC VARCHAR(20),
	CodMeccR CHAR(10),
	DataOraInserimento DATE NOT NULL,
	InseritoreP VARCHAR(30) REFERENCES Persona ON UPDATE CASCADE ON DELETE NO ACTION,
	InseritoreC VARCHAR(20),
	CodMeccI CHAR(10),
	TipoColtivazione VARCHAR(30) NOT NULL,
	Substrato VARCHAR(30) NOT NULL, 
	IdReplica VARCHAR(20) REFERENCES Pianta ON UPDATE CASCADE ON DELETE NO ACTION,
	NFiori INT,
	NFrutti INT,
	PH DOUBLE PRECISION,
	Umidità DOUBLE PRECISION,
	Temperatura DOUBLE PRECISION,
	NFoglie INT,
	PercFoglieDann DOUBLE PRECISION,
	AltezzaPianta DOUBLE PRECISION,
	PesoChiomaFresca DOUBLE PRECISION,
	PesoChiomaSecca DOUBLE PRECISION,
	LunghezzaChioma DOUBLE PRECISION,
	LarghezzaChioma DOUBLE PRECISION,
	LunghezzaRadice DOUBLE PRECISION,
	PesoRadiceFresca DOUBLE PRECISION,
	PesoRadiceSecca DOUBLE PRECISION,
	FOREIGN KEY(RilevatoreC,CodMeccR) 
		REFERENCES Classe(Classe,CodMecc) ON UPDATE CASCADE ON DELETE NO ACTION,
	FOREIGN KEY(InseritoreC,CodMeccI) 
		REFERENCES Classe(Classe,CodMecc) ON UPDATE CASCADE ON DELETE NO ACTION,
	/* CHECK */
	CONSTRAINT check_sintassi_CodRilevazione CHECK (CodRilevazione ~ '^R\d+$'),
	CONSTRAINT check_perc_foglie CHECK(PercFoglieDann<=1 AND PercFoglieDann>=0),
	CONSTRAINT check_ph CHECK(PH<=14 and PH>=0),
	CONSTRAINT check_umidità CHECK(Umidità<=1 and Umidità >=0),
	CONSTRAINT check_RilevatoreP_RilevatoreC_CodMeccR
		CHECK (
			   (RilevatoreP IS NOT NULL AND RilevatoreC IS NULL AND CodMeccR IS NULL)
    		   OR
    		   (RilevatoreP IS NULL AND RilevatoreC IS NOT NULL AND CodMeccR IS NOT NULL)
			  ),
	CONSTRAINT check_InseritoreP_InseritoreC_CodMeccI
		CHECK (
   			   (InseritoreP IS NOT NULL AND InseritoreC IS NULL AND CodMeccI IS NULL)
    		   OR
    		   (InseritoreP IS NULL AND InseritoreC IS NOT NULL AND CodMeccI IS NOT NULL)
			  )
);

/*Popolamento Schema */
/* Finanziamento*/
INSERT INTO Finanziamento VALUES('Piante e Orti','Cura Ambientale');
/* Scuola */
INSERT INTO Scuola VALUES('S123456789','Giuseppe Mazzini','Genova','Liceo Classico','Piante e Orti');
INSERT INTO Scuola VALUES('S344662124','Nicolò Barabino','Genova','Scuola Media','Piante e Orti');
INSERT INTO Scuola VALUES('S893617923','Michele Rossi','Chiavari','Scuola Media','Piante e Orti');
/*Persona */
INSERT INTO Persona VALUES('giacomo.rossi@gmail.com','Giacomo','Rossi','Studente','3757163451', 'S344662124', FALSE);
INSERT INTO Persona VALUES('chiara.bianchi@gmail.com','Chiara','Bianchi','Studente',NULL, 'S893617923', FALSE);
INSERT INTO Persona VALUES('ersilia.verdi@gmail.com','Ersilia','Verdi','Referente','3669421771', 'S123456789', TRUE);
INSERT INTO Persona VALUES('enrico.rossi@gmail.com','Enrico','Rossi','Professore','3751728414', 'S123456789', FALSE);
INSERT INTO Persona VALUES('robertosacco@gmail.com','Roberto','Sacco','Preside',NULL, 'S344662124', FALSE);
/* Classe */
INSERT INTO Classe VALUES('5E','S123456789','Secondaria di secondo grado','enrico.rossi@gmail.com');
INSERT INTO Classe VALUES('3C','S123456789','Secondaria di secondo grado','enrico.rossi@gmail.com');
INSERT INTO Classe VALUES('1A','S344662124','Secondaria di primo grado','robertosacco@gmail.com');
INSERT INTO Classe VALUES('2A','S893617923','Secondaria di primo grado','robertosacco@gmail.com');
/*Specie */
INSERT INTO Specie VALUES('Oryza sativa L.','Riso','Biomonitoraggio', 'Suolo');
INSERT INTO Specie VALUES('Brassica oleracea L.','Cavolo','Biomonitoraggio', 'Vaso');
INSERT INTO Specie VALUES('Brassica napus L.','Colza','Biomonitoraggio', 'Vaso');
INSERT INTO Specie VALUES('Cucumis sativus L.','Cetriolo','Biomonitoraggio', 'Suolo');
INSERT INTO Specie VALUES('Helianthus annuus L.','Girasole','Fitobotanica', 'Suolo');
INSERT INTO Specie VALUES('Tagetes sp. pl.','Tagete','Fitobotanica', 'Suolo');
/* Orto */
INSERT INTO Orto VALUES('Orto1','S344662124',44.40726,8.9338624,40,'Vaso', TRUE);
INSERT INTO Orto VALUES('Orto2','S344662124',44.40726,8.9338624,100,'Suolo', TRUE);
INSERT INTO Orto VALUES('Orto1','S123456789',44.4066928,8.9469156,15.5,'Vaso', FALSE);
INSERT INTO Orto VALUES('Orto3','S123456789',44.4066928,8.9469156,40,'Suolo', TRUE);
INSERT INTO Orto VALUES('Orto4','S893617923',45.3,7.6,50,'Suolo',TRUE);
INSERT INTO Orto VALUES('Orto5','S893617923',45.3,7.6,50,'Suolo',TRUE);
/* Gruppo */
INSERT INTO Gruppo VALUES('G2','Orto3','S123456789','Biomonitoraggio',NULL);
INSERT INTO Gruppo VALUES('G1','Orto1','S123456789','Biomonitoraggio','G2');
INSERT INTO Gruppo VALUES('G7','Orto2','S344662124','Fitobotanica',NULL);
INSERT INTO Gruppo VALUES('G3','Orto1','S344662124','Fitobotanica','G7');
INSERT INTO Gruppo VALUES('G8','Orto5','S893617923','Biomonitoraggio',NULL);
INSERT INTO Gruppo VALUES('G4','Orto4','S893617923','Biomonitoraggio','G8');
/* Strumento */
INSERT INTO Strumento VALUES('S0001','Arduino','MKR ENV Shield','Orto2','S344662124');
INSERT INTO Strumento VALUES('S0002','Sensore','WANFEI ','Orto1','S123456789');
INSERT INTO Strumento VALUES('S0003','Arduino','MKR ENV Shield','Orto1','S344662124');
INSERT INTO Strumento VALUES('S0004','Arduino','MKR ENV Shield','Orto3','S123456789');
/* Pianta */
INSERT INTO Pianta VALUES ('P001',DATE '01-01-2023','Sole','G1','Cucumis sativus L.','S0001');
INSERT INTO Pianta VALUES('P002',DATE '01-04-2023','Sole','G7','Helianthus annuus L.','S0003');
INSERT INTO Pianta VALUES('P003',DATE '05-05-2023','Sole','G1','Brassica oleracea L.','S0004');
INSERT INTO Pianta VALUES('P004',DATE '07-04-2023','Sole','G2','Cucumis sativus L.','S0001');
INSERT INTO Pianta VALUES ('P005',DATE '01-04-2023','Sole','G1','Cucumis sativus L.','S0001');
INSERT INTO Pianta VALUES('P006',DATE '01-04-2023','Sole','G4','Cucumis sativus L.','S0001');
/* Rilevazione */
/* Rilevazione(CodRilevazione,DataOraRilevazione,RilevatorePPersona,RilevatoreC0Classe,
			CodMeccR0Classe,DataOraInserimento,InseritoreP0Persona,InseritoreC0Classe,
			CodMeccI0Classe,TipoColtivazione,Substrato,IdReplicaPianta,NFiori,NFrutti,
			PH,Umidità,Temperatura,NFoglie,PercFoglieDann,AltezzaPianta,PesoChiomaFresca,
			PesoChiomaSecca,LunghezzaChioma,LarghezzaChioma,LunghezzaRadice,PesoRadiceFresca,
			PesoRadiceSecca) */
INSERT INTO Rilevazione 
VALUES('R1',DATE '01-04-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P001',10,5,7,0.3,15,5,0.2,30,12,13,20,25,15,20,7);
INSERT INTO Rilevazione 
VALUES('R2',DATE '01-04-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P002',20,15,5,0.4,11,7,0.3,43,11,11,22,25,12,28,7); 
INSERT INTO Rilevazione 
VALUES('R3',DATE '01-04-2023 16:00:00','giacomo.rossi@gmail.com',NULL,NULL,
	   DATE '01-04-2023 16:30:00','giacomo.rossi@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P001',30,15,6.2,0.62,13.2,10,0.81,11,10,12,13,9,11,8,7);
INSERT INTO Rilevazione
VALUES('R4',DATE '07-04-2023 16:00:00','giacomo.rossi@gmail.com',NULL,NULL,DATE '12-04-2023 12:15:00',
	   'giacomo.rossi@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso','P004',
	   18,12,3.2,0.14,18.7,11,0.85,7,8,5,4,7,10,4,5);
INSERT INTO Rilevazione 
VALUES('R5',DATE '01-06-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '01-06-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P004',20,15,5,0.4,11,7,0.3,43,11,11,22,25,12,28,7); 
INSERT INTO Rilevazione 
VALUES('R6',DATE '12-04-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '12-10-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P001',20,15,5,0.4,11,7,0.3,43,11,11,22,25,12,28,7); 
INSERT INTO Rilevazione 
VALUES('R7',DATE '12-04-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '12-10-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P003',20,15,5,0.4,11,7,0.3,43,11,11,22,25,12,28,7);  
INSERT INTO Rilevazione 
VALUES('R8',DATE '12-04-2023 15:00:00','robertosacco@gmail.com',NULL,NULL,
	   DATE '12-10-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P005',21,16,6,0.7,17,8,0.15,7,9,10,20,21,13,27,4); 
INSERT INTO Rilevazione
VALUES('R9',DATE '12-04-2023 15:00:00','chiara.bianchi@gmail.com',NULL,NULL,
	   DATE '12-10-2023 15:30:00','chiara.bianchi@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P005',21,16,6,0.7,17,8,0.15,7,9,10,20,21,13,27,4);
INSERT INTO Rilevazione
VALUES('R10',DATE '12-04-2023 15:00:00',NULL,'3C','S123456789',
	   DATE '12-10-2023 15:30:00','chiara.bianchi@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
	   'P005',21,16,6,0.7,17,8,0.15,7,9,10,20,21,13,27,4);
INSERT INTO Rilevazione 
VALUES('R11',DATE '01-04-2023 15:00:00',NULL,'5E','S123456789',
       DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
       'P001',10,5,7,0.3,15,5,0.2,30,12,13,20,25,15,20,7);
INSERT INTO Rilevazione 
VALUES('R12',DATE '01-04-2023 15:00:00',NULL,'5E','S123456789',
       DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
       'P001',10,5,7,0.3,15,5,0.2,30,12,13,20,25,15,20,7);
INSERT INTO Rilevazione 
VALUES('R13',DATE '01-04-2023 15:00:00',NULL,'1A','S344662124',
       DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
       'P001',10,5,7,0.3,15,5,0.2,30,12,13,20,25,15,20,7);
INSERT INTO Rilevazione 
VALUES('R14',DATE '01-04-2023 15:00:00',NULL,'2A','S893617923',
       DATE '01-04-2023 15:30:00','robertosacco@gmail.com',NULL,NULL,'In Vaso','Terriccio da rinvaso',
       'P001',10,5,7,0.3,15,5,0.2,30,12,13,20,25,15,20,7);	



/*PARTE 2: VISTA E QUERY*/


/* Vista */
/*La definizione di una vista che fornisca alcune informazioni riassuntive per ogni attività di
biomonitoraggio: per ogni gruppo e per il corrispondente gruppo di controllo mostrare il numero 
di piante, la specie, l’orto in cui è posizionato il gruppo e, su base mensile, 
il valore medio dei parametri ambientali e di crescita delle piante 
(selezionare almeno tre parametri, quelli che si ritengono più significativi). */
CREATE VIEW Biomonitoraggio as
SELECT IdGruppo,GruppoControllo,NomeScientifico,COUNT(DISTINCT IdReplica) as NumeroPiante,NomeOrto,CodMecc,
		EXTRACT(month from DataOraRilevazione) as Mese,AVG(PH) as MediaPH, AVG(AltezzaPianta) as MedAltezzaPianta,
		AVG(Temperatura) as MedTemp
FROM Gruppo JOIN Pianta ON IdGruppo=Gruppo NATURAL JOIN Rilevazione 
GROUP BY IdGruppo,GruppoControllo,NomeScientifico,NomeOrto,CodMecc,EXTRACT(month from DataOraRilevazione)
HAVING Scopo='Biomonitoraggio';
/*** Interrogazioni ***/
/*Determinare le scuole che, pur avendo un finanziamento per il progetto, non hanno inserito 
rilevazioni in questo anno scolastico; */
SELECT codmecc,NomeScuola
FROM Scuola NATURAL JOIN persona LEFT JOIN rilevazione ON email=RilevatoreP
WHERE Progetto IS NOT NULL 
GROUP BY CodMecc
HAVING COUNT(CodRilevazione)=0
INTERSECT
SELECT codmecc,NomeScuola
FROM Scuola LEFT JOIN Rilevazione ON Codmecc=codmeccr
WHERE Progetto IS NOT NULL
GROUP BY codmecc
HAVING COUNT(CodRilevazione)=0;

/*Interrogazioni*/


/* determinare le specie utilizzate in tutti i comuni in cui ci sono scuole aderenti al progetto;*/
SELECT NomeScientifico,Progetto
FROM Scuola X NATURAL JOIN gruppo JOIN pianta on IdGruppo=Gruppo
GROUP BY NomeScientifico,Progetto
HAVING COUNT(DISTINCT Provincia)=
		(SELECT count(DISTINCT Provincia) FROM Scuola GROUP BY progetto HAVING Progetto=X.progetto);
/*determinare per ogni scuola l’individuo/la classe della scuola che ha effettuato più rilevazioni*/
CREATE VIEW RilevaMax as
SELECT CodMecc,nomeScuola,RilevatoreP,rilevatoreC,count(DISTINCT CodRilevazione) as Rilevazioni
FROM Rilevazione join Persona X ON RilevatoreP=email NATURAL JOIN Scuola 
GROUP BY CodMecc,NomeScuola,RilevatoreP,RilevatoreC
HAVING COUNT(DISTINCT codrilevazione)>= ALL (SELECT COUNT(DISTINCT codrilevazione)
								    FROM Rilevazione JOIN Persona ON RilevatoreP=email 
										NATURAL JOIN Scuola 
								    GROUP BY CodMecc,NomeScuola,RilevatoreP
									HAVING CodMecc=X.Codmecc)
UNION
SELECT CodMecc,nomeScuola,rilevatoreP,RilevatoreC,COUNT(DISTINCT CodRilevazione) as Rilevazioni
FROM Rilevazione JOIN Classe X ON CodMeccR=CodMecc NATURAL JOIN Scuola
GROUP BY CodMecc,NomeScuola,RilevatoreC,rilevatorep
HAVING COUNT(DISTINCT codrilevazione)>= ALL (SELECT COUNT(DISTINCT codrilevazione)
								   FROM Rilevazione  JOIN Classe ON CodMeccR=CodMecc 
										NATURAL JOIN Scuola
								    GROUP BY CodMecc,NomeScuola,RilevatoreC
									HAVING CodMecc=X.Codmecc);
SELECT codmecc,nomescuola,rilevatorep,rilevatorec,rilevazioni
FROM RilevaMax X
WHERE rilevazioni >= ALL(SELECT rilevazioni
						  FROM Rilevamax
						  WHERE X.codmecc=codmecc)
GROUP BY codmecc,nomescuola,rilevatorep,rilevatorec,rilevazioni
ORDER BY codmecc;





