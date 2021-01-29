/*************************************************/
/* SCRIPT BDII6_2*/
/*************************************************/
SET AUTOCOMMIT on;

/**********************************************************/
/* 1.- Sentencias de borrado de todas las tablas y vistas */
/**********************************************************/

DROP TABLE INMUEBLE CASCADE CONSTRAINTS;
DROP TABLE VIVIENDA CASCADE CONSTRAINTS;
DROP TABLE PISO CASCADE CONSTRAINTS;
DROP TABLE TRASTERO CASCADE CONSTRAINTS;
DROP TABLE CASA CASCADE CONSTRAINTS;
DROP TABLE LOCAL_COMERCIAL CASCADE CONSTRAINTS;

DROP TABLE SOLAR CASCADE CONSTRAINTS;
DROP TABLE GARAJE CASCADE CONSTRAINTS;
DROP TABLE PERSONA CASCADE CONSTRAINTS;
DROP TABLE TLF CASCADE CONSTRAINTS;
DROP TABLE CLIENTE CASCADE CONSTRAINTS;
DROP TABLE PROPIETARIO CASCADE CONSTRAINTS;
DROP TABLE PARTICULAR CASCADE CONSTRAINTS;

DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE GESTOR CASCADE CONSTRAINTS;
DROP TABLE AGENTE CASCADE CONSTRAINTS;
DROP TABLE CLIENTE_VIP;
DROP TABLE EMPRESA CASCADE CONSTRAINTS;
DROP TABLE VEHICULO CASCADE CONSTRAINTS;

DROP TABLE CITA CASCADE CONSTRAINTS;
DROP TABLE CONTRATO CASCADE CONSTRAINTS;
DROP TABLE TRASPASO CASCADE CONSTRAINTS;
DROP TABLE ALQUILER CASCADE CONSTRAINTS;
DROP TABLE TRANSACCION CASCADE CONSTRAINTS;
DROP TABLE FIRMA CASCADE CONSTRAINTS;
DROP TABLE VISITA CASCADE CONSTRAINTS;

DROP TABLE OPERACION CASCADE CONSTRAINTS;

/* V I S T A S */
DROP VIEW V_TRANSPORTE_AGENTE_VEHICULO;
DROP VIEW V_SALARIOS_EMPLEADO;
DROP VIEW V_TRASTEROSPORPISO_TRASTERO;

/* PROCEDIMIENTOS */
DROP PROCEDURE PROPIETARIOS;
DROP PROCEDURE ACOND_ACT_LOCAL;
DROP PROCEDURE EMP_BAJAR_SUELDO;
DROP PROCEDURE APLICAR_DESCUENTO;
DROP PROCEDURE ACTUALIZAR_PROPIETARIO;

/* FUNCIONES */
DROP FUNCTION CASAS_POR_PLANTAS;
DROP FUNCTION COUNT_ACOND;
DROP FUNCTION AGENTE_POR_ZONA;
DROP FUNCTION NUM_VENTAS_FECHA;



/**************************************************/
/* 2.- Creamos las tablas de nuestro Diagrama EER */
/**************************************************/

CREATE TABLE PERSONA(

    DNI_persona	      		VARCHAR(9),
    direcc_persona     		VARCHAR(100)	NOT NULL,
    nombre_persona     		VARCHAR(45) 	NOT NULL,
    email_personal      	VARCHAR(20) 	NOT NULL,
    num_cuenta_banc_persona VARCHAR(24) 	NOT NULL,

		PRIMARY KEY (DNI_persona),
		UNIQUE 		(email_personal),
		CHECK 		(email_personal LIKE '%_@_%_.__%'),
		CHECK 		(REGEXP_LIKE(DNI_persona, '[0-9]{8}[A-Z]')),
		CHECK 		(REGEXP_LIKE(num_cuenta_banc_persona, '[A-Z]{2}[0-9]{22}'))

);

CREATE TABLE VEHICULO(

	matricula_vehiculo		VARCHAR(8),
	modelo_vehiculo			VARCHAR(24)		NOT NULL,

		PRIMARY KEY (matricula_vehiculo),
        CHECK 		(REGEXP_LIKE(matricula_vehiculo, '[ABCDEFGHIJKLMNOPRSTUVWXYZ][0-9]{6}|[ABCDEFGHIJKLMNOPRSTUVWXYZ][0-9]{4}[ABCDEFGHIJKLMNOPRSTUVWXYZ]{2}|[0-9]{4}[BCDFGHJKLMNPRSTVWXYZ]{3}'))

);

CREATE TABLE EMPLEADO(

	tipo_contrato 			VARCHAR(16) 	DEFAULT 'temporal',
	salario 				DECIMAL(8,2) 	NOT NULL,
	DNI_empleado 			VARCHAR(9),

		PRIMARY KEY	(DNI_empleado),
		FOREIGN KEY (DNI_empleado) REFERENCES PERSONA 
			ON DELETE CASCADE,
		CHECK 		(tipo_contrato IN ('temporal', 'fijo', 'practicas')),
		CHECK 		(salario > 0)

);

CREATE TABLE AGENTE(

	comision				DECIMAL(8,2),
	zona_ciudad	 			VARCHAR(8)  	NOT NULL,
	DNI_agente	 			VARCHAR(9),
	matricula_vehiculo		VARCHAR(8) 		NOT NULL,

		PRIMARY KEY (DNI_agente),
		FOREIGN KEY (DNI_agente) REFERENCES EMPLEADO
			ON DELETE CASCADE,
		FOREIGN KEY (matricula_vehiculo) REFERENCES VEHICULO, /*No action*/
		CHECK 		(zona_ciudad IN ('norte', 'sur', 'este', 'oeste', 'centro'))

);

CREATE TABLE GESTOR(

	oficina 				VARCHAR(3)		NOT NULL,
	email_empresa 			VARCHAR(32),
	contrasena				VARCHAR(32) 	NOT NULL,
	DNI_gestor	 			VARCHAR(9),

		PRIMARY KEY (DNI_gestor),
		FOREIGN KEY (DNI_gestor) REFERENCES EMPLEADO
			ON DELETE CASCADE,
		UNIQUE 		(email_empresa),
		CHECK 		(email_empresa LIKE '%@inmobiliaria.com'),
		CHECK 		(LENGTH(contrasena)>=8 AND LENGTH(contrasena)<=32)

);
		
CREATE TABLE PROPIETARIO(

	num_propiedades  		NUMBER(2) 		DEFAULT 1,
	DNI_propietario        	VARCHAR(9),

		PRIMARY KEY	(DNI_propietario),
		FOREIGN KEY (DNI_propietario) REFERENCES PERSONA
			ON DELETE CASCADE,
		CHECK 		(num_propiedades >0)

);

CREATE TABLE CLIENTE(

	descuento				DECIMAL(4,2),
	ind_morosidad  			DECIMAL(5,2),
	ID_recomendado  		NUMBER(10),
    DNI_agente       		VARCHAR(9) 		NOT NULL,
	ID_cliente        		NUMBER(10),
		
		PRIMARY KEY (ID_cliente),
		FOREIGN KEY (DNI_agente) REFERENCES AGENTE,
		CHECK 		(descuento >=0 AND descuento <= 80),
		CHECK 		(ind_morosidad >=0 AND ind_morosidad <= 100)

);

/* REFLEXIVA */ 
ALTER TABLE CLIENTE ADD FOREIGN KEY(ID_recomendado) REFERENCES  CLIENTE(ID_cliente) ON DELETE SET NULL;


CREATE TABLE PARTICULAR(

	estado_civil  			VARCHAR(11) 	NOT NULL,
	estudiante  			NUMBER(1) 		DEFAULT 0 NOT NULL,
	DNI           			VARCHAR(9),
	id_cliente       		NUMBER(10) 		NOT NULL,

		PRIMARY KEY (DNI),
		FOREIGN KEY (DNI) REFERENCES PERSONA
			ON DELETE CASCADE,
		FOREIGN KEY (id_cliente) REFERENCES CLIENTE
			ON DELETE CASCADE,
		CHECK 		(estudiante IN (0,1)),
		CHECK 		(estado_civil IN ('SOLTERO', 'CASADO', 'UNIÓN LIBRE', 'SEPARADO', 'DIVORCIADO', 'VIUDO'))

);

CREATE TABLE CLIENTE_VIP(

	descuento_vip  			NUMBER(2)		DEFAULT 10 NOT NULL,
	DNI_cliente_vip			VARCHAR(9),

		PRIMARY KEY (DNI_cliente_vip),
		FOREIGN KEY (DNI_cliente_vip) REFERENCES PARTICULAR
			ON DELETE CASCADE,
		FOREIGN KEY (DNI_cliente_vip) REFERENCES EMPLEADO
			ON DELETE CASCADE,
		CHECK 		(descuento_vip >= 0 AND descuento_vip < 80)

);

CREATE TABLE INMUEBLE(

	num_catastro			VARCHAR(20),
	superficie_inmueble		DECIMAL(7,3)	NOT NULL,
	provincia				VARCHAR(24) 	NOT NULL,
	ciudad					VARCHAR(44) 	NOT NULL,
	calle					VARCHAR(35) 	NOT NULL,
	numero					NUMBER(3)		NOT NULL,
	DNI_gestor				VARCHAR(9)		NOT NULL,
	DNI_propietario			VARCHAR(9)		NOT NULL,

		PRIMARY KEY	(num_catastro),
		FOREIGN KEY	(DNI_gestor) REFERENCES GESTOR, /*No action*/
		FOREIGN KEY	(DNI_propietario) REFERENCES PROPIETARIO, /*No action*/
		CHECK		(superficie_inmueble > 5),
        CHECK 		(REGEXP_LIKE(num_catastro, '[0-9]{7}[A-Z]{2}[0-9]{4}[A-Z][0-9]{4}[A-Z]{2}')),
		CHECK		(NUMERO > 0)

);
		
CREATE TABLE TLF(

	numero    				NUMBER(9),
	DNI           			VARCHAR(9),

		PRIMARY KEY	(DNI, numero),
		FOREIGN KEY	(DNI) REFERENCES PERSONA
			ON DELETE CASCADE,
		CHECK 		(REGEXP_LIKE(numero, '[6-9][0-9]{8}')) /*Formato de telefonos españoles*/

);

CREATE TABLE EMPRESA(

	CIF				        VARCHAR(9),
	sector_empresarial		VARCHAR(32)		NOT NULL,
	capital_social			DECIMAL(12,2)	NOT NULL,
	id_cliente			    NUMBER(10)		NOT NULL,

		PRIMARY KEY (CIF),
		FOREIGN KEY (id_cliente) REFERENCES CLIENTE
			ON DELETE CASCADE,
        CHECK 		(REGEXP_LIKE(CIF, '[A-Z][0-9]{8}')),
        CHECK 		(capital_social>=3000)
		
);

CREATE TABLE VIVIENDA(

	num_catastro			VARCHAR(20),
	amueblado				NUMBER(1) 		NOT NULL,
	ano_construccion		NUMBER(4) 		NOT NULL,
	num_banos				NUMBER(2) 		NOT NULL,
	num_habitaciones	 	NUMBER(2) 		NOT NULL,
	
		PRIMARY KEY	(num_catastro),
		FOREIGN KEY	(num_catastro) REFERENCES INMUEBLE
			ON DELETE CASCADE,
		CHECK		(amueblado=0 OR amueblado=1),
		CHECK		(ano_construccion > 1850 AND ano_construccion < 2020), /*SELECT YEAR(GETDATE()); No funciona??*/	
		CHECK		(num_banos > 0),						
		CHECK		(num_habitaciones > 0)

);
		
CREATE TABLE CASA(

		num_catastro		VARCHAR(20),
		plantas_casa	 	NUMBER(4) 		NOT NULL ,
		
		PRIMARY KEY	(num_catastro),
		FOREIGN KEY	(num_catastro) REFERENCES VIVIENDA
			ON DELETE CASCADE,
		CHECK		(plantas_casa >= 0));

CREATE TABLE PISO(

	NUM_CATASTRO			VARCHAR(20),
	PLANTA_PISO				NUMBER(3) 		NOT NULL,
	LETRA_PISO 				VARCHAR(1) 		NOT NULL,

		PRIMARY KEY	(NUM_CATASTRO),
		FOREIGN KEY	(NUM_CATASTRO) REFERENCES VIVIENDA
			ON DELETE CASCADE,
		CHECK		(PLANTA_PISO >= 0),
		CHECK		(LETRA_PISO IN('A','B','C','D','E','F','G','H','I','J','K','L','M','N'))

);

CREATE TABLE TRASTERO(

	num_catastro			VARCHAR(20),
	numero_trastero			NUMBER(4) ,
	planta_trastero			NUMBER(3) 		NOT NULL,

		PRIMARY KEY	(num_catastro,numero_trastero),
		FOREIGN KEY	(num_catastro) REFERENCES PISO
			ON DELETE CASCADE,
		CHECK		(planta_trastero >= 0),
		CHECK		(numero_trastero >= 0)

);

CREATE TABLE LOCAL_COMERCIAL(

	num_catastro			VARCHAR(20),
	planta_local 			NUMBER(4)       NOT NULL ,
	acond_local 			VARCHAR(30)     DEFAULT 'VACIO' NOT NULL,
	actividad_local			VARCHAR(30)     NOT NULL,

		PRIMARY KEY (num_catastro),
		FOREIGN KEY (num_catastro) REFERENCES INMUEBLE
			ON DELETE CASCADE,
		CHECK       (planta_local >= 0),
		CHECK       (acond_local IN('VACIO','RESTAURANTE','BAR','RESTAURANTE-BAR','PELUQUERIA','ALMACEN','LIBRERIA','TECNOLOGIA')),
		CHECK       (actividad_local IN('RESTAURANTE','BAR','RESTAURANTE-BAR','PELUQUERIA','ALMACEN','LIBRERIA','TECNOLOGIA','SIN ESPECIFICAR'))

);
        
CREATE TABLE SOLAR(

	edificable_solar		NUMBER(1) 		DEFAULT 1,
	num_catastro			VARCHAR(20),

		PRIMARY KEY (num_catastro),
		FOREIGN KEY (num_catastro) REFERENCES INMUEBLE 
            ON DELETE CASCADE,
        CHECK       (edificable_solar IN (0, 1))

);

CREATE TABLE GARAJE(

	plazas_garaje	        NUMBER(2)       DEFAULT 1 NOT NULL,
	num_catastro	        VARCHAR(20),

		PRIMARY KEY (num_catastro),
		FOREIGN KEY (num_catastro) REFERENCES INMUEBLE 
            ON DELETE CASCADE

);

CREATE TABLE CITA(

	id_cita				    VARCHAR(16),		
	hora_cita			    VARCHAR(5)		NOT NULL, /*TIME no funcionaba*/
	fecha_cita			    DATE			NOT NULL,
	lugar_cita			    VARCHAR(20)		NOT NULL,
	DNI_agente			    VARCHAR(9)		NOT NULL,
	id_cliente			    NUMBER(10)		NOT NULL,

		PRIMARY KEY (id_cita),
		FOREIGN KEY (DNI_agente) REFERENCES AGENTE, /*no action*/
        FOREIGN KEY (id_cliente) REFERENCES CLIENTE
        	ON DELETE CASCADE,
        CHECK       (hora_cita LIKE '%:%')

);
        
CREATE TABLE OPERACION(

	id_operacion			VARCHAR(16),
	estado				    VARCHAR(16)		NOT NULL,

		PRIMARY KEY (id_operacion),
        CHECK 		(estado IN ('FINALIZADA', 'PENDIENTE'))
);


CREATE TABLE TRASPASO(

	id_operacion			VARCHAR(16),
	deudas			        DECIMAL(7,2),
	fecha_efectiva			DATE			NOT NULL,

		PRIMARY KEY (id_operacion),
		FOREIGN KEY (id_operacion) REFERENCES OPERACION,
		CHECK		(deudas >= 0)

);


CREATE TABLE ALQUILER(

	id_operacion			VARCHAR(16),
	fianza					DECIMAL(7,2)	NOT NULL,
	fecha_ent				DATE			NOT NULL,
	fecha_sal				DATE			NOT NULL,

		PRIMARY KEY (id_operacion),
	    FOREIGN KEY (id_operacion) REFERENCES OPERACION,
		CHECK(fianza > 0)

);

CREATE TABLE CONTRATO(

	id_contrato				VARCHAR(16),
	importe					DECIMAL(8,2)	NOT NULL,
	forma_pago				VARCHAR(13)		DEFAULT 'transferencia' NOT NULL,
	id_operacion			VARCHAR(16)		NOT NULL,
    inmueble                VARCHAR(20)       NOT NULL,

        PRIMARY KEY (id_contrato),
        FOREIGN KEY (id_operacion) REFERENCES OPERACION
            ON DELETE CASCADE,
        FOREIGN KEY (inmueble) REFERENCES INMUEBLE, /*no action*/
        CHECK 		(forma_pago IN ('transferencia', 'efectivo')),
        CHECK 		(importe > 0)

);

CREATE TABLE TRANSACCION(

	id_operacion			VARCHAR(16),
	id_contrato				VARCHAR(16),
	/*fecha_firma				DATE			NOT NULL,*/
	id_cliente				NUMBER(10)		NOT NULL,
	DNI_propietario		    VARCHAR(9)		NOT NULL,

		PRIMARY KEY (id_operacion, id_contrato),
		FOREIGN KEY (id_operacion) REFERENCES OPERACION
			ON DELETE CASCADE,
		FOREIGN KEY (id_contrato) REFERENCES CONTRATO
			ON DELETE CASCADE,
		FOREIGN KEY (id_cliente) REFERENCES CLIENTE, /*no action*/
		FOREIGN KEY (DNI_propietario) REFERENCES PROPIETARIO /*no action*/ 

);

CREATE TABLE FIRMA(
	
	fecha_firma				DATE			NOT NULL,
	id_cliente_firma		NUMBER(10),
	id_operacion_firma		VARCHAR(16),
	id_contrato_firma		VARCHAR(16),
	
		PRIMARY KEY (id_operacion_firma, id_contrato_firma, id_cliente_firma),
		FOREIGN KEY (id_operacion_firma, id_contrato_firma) REFERENCES TRANSACCION
			ON DELETE CASCADE,
		FOREIGN KEY (id_cliente_firma) REFERENCES CLIENTE
			ON DELETE CASCADE

);

CREATE TABLE VISITA(

	id_cita					VARCHAR(16),
	num_catastro				VARCHAR(20),

		PRIMARY KEY (id_cita, num_catastro),
		FOREIGN KEY (id_cita) REFERENCES CITA
            			ON DELETE CASCADE,
		FOREIGN KEY (num_catastro) REFERENCES INMUEBLE /*no action*/

);	



/*******************************************************/
/* 3.- Creamos los índices necesarios sobre las tablas */
/*******************************************************/

CREATE INDEX CITAS_FECHA ON CITA (fecha_cita ASC);
CREATE INDEX SUELDO ON EMPLEADO (salario);
CREATE INDEX TIPO_OPERACION ON CONTRATO (id_operacion);




/************************************************/
/* 4.- Creamos las vistas para nuestra temática */
/************************************************/

/*Acceder más facilmente a los coches que tiene cada empleado*/

CREATE OR REPLACE VIEW V_TRANSPORTE_AGENTE_VEHICULO (DNIAGENTE,MATRICULA,MODELO )
  AS SELECT A.DNI_agente,V.matricula_vehiculo,V.modelo_vehiculo 
FROM AGENTE A, VEHICULO V
WHERE V.matricula_vehiculo=A.matricula_vehiculo;

/* Ver el salario de todos los empleados*/

CREATE OR REPLACE VIEW V_SALARIOS_EMPLEADO (DNI,SALARIO)
  AS SELECT DNI_empleado, salario FROM EMPLEADO;

/* Ver los trasteros que tiene cada piso */
CREATE OR REPLACE VIEW V_TRASTEROSPORPISO_TRASTERO (PISO,NUMTRASTEROS)
  AS SELECT num_catastro, COUNT(*) FROM TRASTERO
 GROUP BY num_catastro;




/*********************************************************/
/* 5.- Insertamos datos de ejemplo para todas las tablas */
/*********************************************************/

/*PERSONA*/
INSERT INTO PERSONA VALUES('93963356F','Curros Enrriquez 1 4B','Pepe Gómez Fernandez','pepe@gmail.com','ES3701849325559816401771');
INSERT INTO PERSONA VALUES('23985158E','Rua Otero Pedrayo 2 3A','Maria Gómez Blanzo','maria@gmail.com','ES2514698820720593308829');
INSERT INTO PERSONA VALUES('14188557H','Bedoya 4 2C','Josefa Rojo Exposito','josefa@gmail.com','ES2514698820815593308829');
INSERT INTO PERSONA VALUES('25409266Q','Posío 69 7B','Mario Baleato Ordoñez','mario15@gmail.com','ES1220622527616683583785');
INSERT INTO PERSONA VALUES('41922835E','Travesia de Cabeza de Manzaneda  1 s/n','Alejandro Pérez','alex@gmail.com','ES6101131912265518414484');
INSERT INTO PERSONA VALUES('00734219J','Zahara de los Atunes 1 5B','Manuel Estévez Fernández','manuel@gmail.com','ES7901674664322542816445');
INSERT INTO PERSONA VALUES('01806642S','Amoeiro 1 6B','David Gómez Noya','david@gmail.com','ES9730966060918074021946');
INSERT INTO PERSONA VALUES('62254585W','Calle Neptuno 25 6B','Luis Pérez Rodriguez','luis@gmail.com','ES6120067211086260323998');

/*VEHICULO*/
INSERT INTO VEHICULO(matricula_vehiculo, modelo_vehiculo) VALUES ('1234FXD', 'Ford Fiesta');
INSERT INTO VEHICULO(matricula_vehiculo, modelo_vehiculo) VALUES ('5678HNM', 'Kia Picanto');
INSERT INTO VEHICULO(matricula_vehiculo, modelo_vehiculo) VALUES ('1010CHN', 'Citroen Berlingo');

/*EMPLEADO*/
INSERT INTO EMPLEADO (tipo_contrato, salario, DNI_empleado) VALUES ('fijo', '1200', '93963356F');
INSERT INTO EMPLEADO (tipo_contrato, salario, DNI_empleado) VALUES ('fijo', '1300', '23985158E');
INSERT INTO EMPLEADO (tipo_contrato, salario, DNI_empleado) VALUES ('temporal', '1100', '14188557H');
INSERT INTO EMPLEADO (tipo_contrato, salario, DNI_empleado) VALUES ('practicas', '700', '25409266Q');

/*AGENTE*/
INSERT INTO AGENTE (comision, zona_ciudad, DNI_agente, matricula_vehiculo) VALUES (200.00, 'centro', '93963356F', '1234FXD');
INSERT INTO AGENTE (comision, zona_ciudad, DNI_agente, matricula_vehiculo) VALUES (100.00, 'este', '23985158E', '5678HNM');

/*GESTOR*/
INSERT INTO GESTOR (oficina, email_empresa, contrasena, DNI_gestor) VALUES ('1A', 'gestor1@inmobiliaria.com', '1234abcd', '14188557H');
INSERT INTO GESTOR (oficina, email_empresa, contrasena, DNI_gestor) VALUES ('1B', 'gestor2@inmobiliaria.com', 'abcd1234', '25409266Q');

/*PROPIETARIO*/
INSERT INTO PROPIETARIO VALUES(3,'41922835E');
INSERT INTO PROPIETARIO VALUES(9,'00734219J');
INSERT INTO PROPIETARIO VALUES(4,'62254585W');

/*CLIENTE*/
INSERT INTO CLIENTE VALUES(	10.5,	0,	NULL,		'93963356F',	0000000001);
INSERT INTO CLIENTE VALUES(	7.5,	15,	NULL,		'93963356F',	0000000002);
INSERT INTO CLIENTE VALUES(	6.5,	0.5,0000000001,	'23985158E',	0000000003);
INSERT INTO CLIENTE VALUES(	6.5,	5,	0000000002,	'23985158E',	0000000004);
INSERT INTO CLIENTE VALUES(	6.5,	2,	0000000002,	'23985158E',	0000000005);
INSERT INTO CLIENTE VALUES(	2.5,	3,	NULL,		'23985158E',	0000000009);

INSERT INTO CLIENTE VALUES(7.1,2,NULL,'23985158E',0000000006);
INSERT INTO CLIENTE VALUES(8.2,2,NULL,'93963356F',0000000007);
INSERT INTO CLIENTE VALUES(9.3,0.1,NULL,'23985158E',0000000008);

/*PARTICULAR*/
INSERT INTO PARTICULAR VALUES('CASADO',0,'41922835E',0000000001);
INSERT INTO PARTICULAR VALUES('SOLTERO',0,'00734219J',0000000002);
INSERT INTO PARTICULAR VALUES('VIUDO',0,'01806642S',0000000003);
INSERT INTO PARTICULAR VALUES('CASADO',0,'93963356F',0000000004);
INSERT INTO PARTICULAR VALUES('SOLTERO',1,'14188557H',0000000005);
INSERT INTO PARTICULAR VALUES('SOLTERO',0,'62254585W',0000000009);

/*CLIENTE_VIP*/
INSERT INTO CLIENTE_VIP (descuento_vip, DNI_cliente_vip) VALUES (20, '93963356F');
INSERT INTO CLIENTE_VIP (descuento_vip, DNI_cliente_vip) VALUES (10, '14188557H');

/*INMUEBLE VIVIENDA PISO*/
INSERT INTO INMUEBLE VALUES('9872023VH5797S0001WX','410','OURENSE','OURENSE','Otero Pedrayo','21','14188557H','41922835E');
INSERT INTO INMUEBLE VALUES('5367893VH5797S0001XX','410','OURENSE','OURENSE','Barbadas','21','14188557H','41922835E');
INSERT INTO INMUEBLE VALUES('4435673JT5797S0001AE','230','OURENSE','OURENSE','Bella Otero','44','14188557H','00734219J');
/*INMUEBLE VIVIENDA CASA*/
INSERT INTO INMUEBLE VALUES('5323023VH5797S0001FD','130','OURENSE','OURENSE','Chano Piñeiro','11','25409266Q','00734219J');
INSERT INTO INMUEBLE VALUES('5323666VH5797S0041FD','170','OURENSE','OURENSE','Calle del Paseo','15','25409266Q','00734219J');
INSERT INTO INMUEBLE VALUES('6789876VH5797S0041HJ','240','OURENSE','OURENSE','El retiro','17','25409266Q','00734219J');
/*INMUEBLE LOCAL*/
INSERT INTO INMUEBLE VALUES('5326323TT5797S0001FD','320','OURENSE','OURENSE','Avd. Salesianos','41','14188557H','62254585W');
INSERT INTO INMUEBLE VALUES('5343323TT5797S0001FD','570','OURENSE','OURENSE','O burgo','43','14188557H','41922835E');
INSERT INTO INMUEBLE VALUES('1326323TT5797S0001YT','120','OURENSE','OURENSE','Cumial','22','14188557H','62254585W');
INSERT INTO INMUEBLE VALUES('5678323TT5797S0001DE','320','OURENSE','OURENSE','Fonsilon','32','14188557H','62254585W');
/*INMUEBLE SOLAR*/
INSERT INTO INMUEBLE VALUES('1326323TT5797S0002YT','820','OURENSE','OURENSE','Celso Emilio Ferreiro" ','52','14188557H','62254585W');
INSERT INTO INMUEBLE VALUES('1326323TT5797S0003YT','630','OURENSE','OURENSE','Rosalia de Castro','33','14188557H','00734219J');
INSERT INTO INMUEBLE VALUES('1326323TT5797S0004YT','820','OURENSE','OURENSE','Calle Aragon','112','14188557H','00734219J');
/*INMUEBLE GARAJE*/
INSERT INTO INMUEBLE VALUES('1326323TT5797S0005YT','240','OURENSE','OURENSE','Calle Neptuno','122','14188557H','00734219J');
INSERT INTO INMUEBLE VALUES('1326323TT5797S0006YT','420','OURENSE','OURENSE','Calle Jupiter','123','14188557H','00734219J');
INSERT INTO INMUEBLE VALUES('1326323TT5797S0007YT','120','OURENSE','OURENSE','Calle Rio Deva','124','14188557H','00734219J');

/*TLF*/
INSERT INTO TLF VALUES(666001122,'41922835E');
INSERT INTO TLF VALUES(988001122,'41922835E');
INSERT INTO TLF VALUES(988001133,'00734219J');

/*EMPRESA*/
INSERT INTO EMPRESA (CIF, sector_empresarial, capital_social, id_cliente) VALUES ('A10101010', 'restauracion', 20000.00, 0000000006);
INSERT INTO EMPRESA (CIF, sector_empresarial, capital_social, id_cliente) VALUES ('B21212121', 'seguros', 60000.00, 0000000007);
INSERT INTO EMPRESA (CIF, sector_empresarial, capital_social, id_cliente) VALUES ('C32323232', 'turismo', 45000.00, 0000000008);

/*VIVIENDA PISO*/
INSERT INTO VIVIENDA VALUES ('9872023VH5797S0001WX','0',2007,1,2);
INSERT INTO VIVIENDA VALUES ('5367893VH5797S0001XX','0',2012,1,3);
INSERT INTO VIVIENDA VALUES ('4435673JT5797S0001AE','1',2018,2,2);
/*VIVIENDA CASA*/
INSERT INTO VIVIENDA VALUES ('5323023VH5797S0001FD','0',2002,2,3);
INSERT INTO VIVIENDA VALUES ('5323666VH5797S0041FD','1',2015,2,5);
INSERT INTO VIVIENDA VALUES ('6789876VH5797S0041HJ','1',2013,2,3);

/*CASA*/
INSERT INTO CASA VALUES('5323023VH5797S0001FD','4');
INSERT INTO CASA VALUES('5323666VH5797S0041FD','2');
INSERT INTO CASA VALUES('6789876VH5797S0041HJ','1');

/*PISO*/
INSERT INTO PISO VALUES ('9872023VH5797S0001WX',2,'D');
INSERT INTO PISO VALUES ('5367893VH5797S0001XX',4,'F');
INSERT INTO PISO VALUES ('4435673JT5797S0001AE',3,'C');

/*TRASTERO*/
INSERT INTO TRASTERO VALUES ('9872023VH5797S0001WX','001','6');
INSERT INTO TRASTERO VALUES ('9872023VH5797S0001WX','002','6');
INSERT INTO TRASTERO VALUES ('9872023VH5797S0001WX','003','7');
INSERT INTO TRASTERO VALUES ('5367893VH5797S0001XX','001','10');
INSERT INTO TRASTERO VALUES ('5367893VH5797S0001XX','002','10');
INSERT INTO TRASTERO VALUES ('5367893VH5797S0001XX','003','14');
INSERT INTO TRASTERO VALUES ('4435673JT5797S0001AE','001','6');
INSERT INTO TRASTERO VALUES ('4435673JT5797S0001AE','002','6');

/*LOCAL*/
INSERT INTO LOCAL_COMERCIAL VALUES ('5326323TT5797S0001FD',0,'VACIO','ALMACEN');
INSERT INTO LOCAL_COMERCIAL VALUES ('5343323TT5797S0001FD',1,'RESTAURANTE','RESTAURANTE');
INSERT INTO LOCAL_COMERCIAL VALUES ('1326323TT5797S0001YT',0,'PELUQUERIA','TECNOLOGIA');
INSERT INTO LOCAL_COMERCIAL VALUES ('5678323TT5797S0001DE',0,'VACIO','SIN ESPECIFICAR');

/*SOLAR*/
INSERT INTO SOLAR VALUES(1,'1326323TT5797S0002YT');
INSERT INTO SOLAR VALUES(1,'1326323TT5797S0003YT');
INSERT INTO SOLAR VALUES(0,'1326323TT5797S0004YT');

/*GARAJE*/
INSERT INTO GARAJE VALUES(1,'1326323TT5797S0005YT');
INSERT INTO GARAJE VALUES(1,'1326323TT5797S0006YT');
INSERT INTO GARAJE VALUES(2,'1326323TT5797S0007YT');

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
/*CITA*/
INSERT INTO CITA(id_cita, hora_cita, fecha_cita, lugar_cita, DNI_agente, id_cliente) VALUES('cita_41922835E','16:30','2020-05-03','barbadas','93963356F',0000000002);
INSERT INTO CITA(id_cita, hora_cita, fecha_cita, lugar_cita, DNI_agente, id_cliente) VALUES ('cita_99999999B', '17:45','2020-12-21','barbadas','23985158E',	0000000003);
INSERT INTO CITA(id_cita, hora_cita, fecha_cita, lugar_cita, DNI_agente, id_cliente) VALUES ('cita_11223344F','10:00','2020-01-10','barrocanes','93963356F',0000000009);


/*Operacion*/

INSERT INTO OPERACION(id_operacion,estado) VALUES ('AL00001','FINALIZADA');
INSERT INTO OPERACION(id_operacion,estado) VALUES ('AL00002','FINALIZADA');
INSERT INTO OPERACION(id_operacion,estado) VALUES ('AL00003','FINALIZADA');
INSERT INTO OPERACION(id_operacion,estado) VALUES ('TR00001','PENDIENTE');
INSERT INTO OPERACION(id_operacion,estado) VALUES ('TR00002','PENDIENTE');

/*TRASPASO*/
INSERT INTO TRASPASO(id_operacion, deudas, fecha_efectiva) VALUES ('TR00001', NULL, '2020-07-11');
INSERT INTO TRASPASO(id_operacion, deudas, fecha_efectiva) VALUES ('TR00002', NULL, '2020-09-07');


/*ALQUILER*/
INSERT INTO ALQUILER(id_operacion, fianza, fecha_ent, fecha_sal) VALUES ('AL00001', 450.00, '2020-09-01', '2021-09-01');	
INSERT INTO ALQUILER(id_operacion, fianza, fecha_ent, fecha_sal) VALUES ('AL00002', 500.00, '2020-09-01', '2022-09-01');
INSERT INTO ALQUILER(id_operacion, fianza, fecha_ent, fecha_sal) VALUES ('AL00003', 300.00, '2020-02-06', '2023-09-01');


/*CONTRATO*/
INSERT INTO CONTRATO(id_contrato, importe, forma_pago, id_operacion, inmueble) VALUES ('CON00001', 450.00, 'efectivo', 'TR00001', '9872023VH5797S0001WX');
INSERT INTO CONTRATO(id_contrato, importe, forma_pago, id_operacion, inmueble) VALUES ('CON00002', 500.00, 'efectivo', 'TR00002', '5367893VH5797S0001XX');
INSERT INTO CONTRATO(id_contrato, importe, forma_pago, id_operacion, inmueble) VALUES ('CON00003', 55000.00, 'transferencia', 'AL00001', '4435673JT5797S0001AE');
INSERT INTO CONTRATO(id_contrato, importe, forma_pago, id_operacion, inmueble) VALUES ('CON00004', 100000.00, 'transferencia', 'AL00002', '5326323TT5797S0001FD');
INSERT INTO CONTRATO(id_contrato, importe, forma_pago, id_operacion, inmueble) VALUES ('CON00005', 300.00, 'efectivo', 'AL00003', '1326323TT5797S0001YT');


/*TRANSACCION*/
INSERT INTO TRANSACCION(id_operacion, id_contrato, id_cliente, DNI_propietario) VALUES ('TR00001', 'CON00001', 0000000002, '41922835E');
INSERT INTO TRANSACCION(id_operacion, id_contrato, id_cliente, DNI_propietario) VALUES ('TR00002', 'CON00002', 0000000002, '41922835E');
INSERT INTO TRANSACCION(id_operacion, id_contrato, id_cliente, DNI_propietario) VALUES ('AL00001', 'CON00003', 0000000003, '00734219J');
INSERT INTO TRANSACCION(id_operacion, id_contrato, id_cliente, DNI_propietario) VALUES ('AL00002', 'CON00004', 0000000007, '62254585W');
INSERT INTO TRANSACCION(id_operacion, id_contrato, id_cliente, DNI_propietario) VALUES ('AL00003', 'CON00005', 0000000007, '62254585W');

/*FIRMA*/
INSERT INTO FIRMA(fecha_firma, id_cliente_firma, id_operacion_firma, id_contrato_firma) VALUES ('2020-09-15', 0000000002, 'TR00001', 'CON00001');
INSERT INTO FIRMA(fecha_firma, id_cliente_firma, id_operacion_firma, id_contrato_firma) VALUES ('2020-03-17', 0000000002, 'TR00002', 'CON00002');
INSERT INTO FIRMA(fecha_firma, id_cliente_firma, id_operacion_firma, id_contrato_firma) VALUES ('2020-02-18', 0000000003, 'AL00001', 'CON00003');
INSERT INTO FIRMA(fecha_firma, id_cliente_firma, id_operacion_firma, id_contrato_firma) VALUES ('2020-01-25', 0000000007, 'AL00002', 'CON00004');
INSERT INTO FIRMA(fecha_firma, id_cliente_firma, id_operacion_firma, id_contrato_firma) VALUES ('2020-07-01', 0000000007, 'AL00003', 'CON00005');


/*VISITA*/
INSERT INTO VISITA(id_cita, num_catastro) VALUES ('cita_41922835E', '5323023VH5797S0001FD');
INSERT INTO VISITA(id_cita, num_catastro) VALUES ('cita_99999999B', '9872023VH5797S0001WX');
INSERT INTO VISITA(id_cita, num_catastro) VALUES ('cita_11223344F', '6789876VH5797S0041HJ');



/********************************************/
/* 6.- Incluímos sentencias de comprobación */
/********************************************/

/* TABLAS */
SELECT * FROM AGENTE;
SELECT * FROM ALQUILER;
SELECT * FROM CASA;
SELECT * FROM CITA;
SELECT * FROM CLIENTE;
SELECT * FROM CLIENTE_VIP;
SELECT * FROM CONTRATO;
SELECT * FROM EMPLEADO;
SELECT * FROM EMPRESA;
SELECT * FROM GARAJE;
SELECT * FROM GESTOR;
SELECT * FROM INMUEBLE;
SELECT * FROM LOCAL_COMERCIAL;
SELECT * FROM OPERACION;
SELECT * FROM PARTICULAR;
SELECT * FROM PERSONA;
SELECT * FROM PISO;
SELECT * FROM PROPIETARIO;
SELECT * FROM SOLAR;
SELECT * FROM TLF;
SELECT * FROM TRANSACCION;
SELECT * FROM FIRMA;
SELECT * FROM TRASPASO;
SELECT * FROM TRASTERO;
SELECT * FROM VEHICULO;
SELECT * FROM VISITA;
SELECT * FROM VIVIENDA;

/* VISTAS */

SELECT * FROM V_TRANSPORTE_AGENTE_VEHICULO; /*MAL*/
/*UPDATE V_TRANSPORTE_AGENTE_VEHICULO SET MATRICULA = '1010CHN' WHERE DNIAGENTE = '93963356F';/*NO FUNCIONA*/
/*DELETE FROM V_TRANSPORTE_AGENTE_VEHICULO WHERE DNIAGENTE = '93963356F';/*NO FUNCIONA*/
/*DELETE FROM V_TRANSPORTE_AGENTE_VEHICULO WHERE MATRICULA = '1234FXD';/*NO FUNCIONA*/
SELECT * FROM V_TRANSPORTE_AGENTE_VEHICULO;

SELECT * FROM V_SALARIOS_EMPLEADO; /*MAL*/
UPDATE V_SALARIOS_EMPLEADO SET SALARIO = 2000 WHERE DNI = '14188557H'; /*FUNCIONA*/
/*DELETE FROM V_SALARIOS_EMPLEADO WHERE SALARIO = 1300; /*NO FUNCIONA*/
/*DELETE FROM V_SALARIOS_EMPLEADO WHERE DNI = '93963356F'; /*NO FUNCIONA*/
SELECT * FROM V_SALARIOS_EMPLEADO;

SELECT * FROM V_TRASTEROSPORPISO_TRASTERO; /*BIEN*/
/*UPDATE V_TRASTEROSPORPISO_TRASTERO SET NUMTRASTEROS = 4 WHERE PISO = '9872023VH5797S0001WX'; /*NO FUNCIONA*/
/*DELETE FROM V_TRASTEROSPORPISO_TRASTERO WHERE NUMTRASTEROS = 3; /*NO FUNCIONA*/
/*DELETE FROM V_TRASTEROSPORPISO_TRASTERO WHERE PISO = '5367893VH5797S0001XX'; /*NO FUNCIONA*/
SELECT * FROM V_TRASTEROSPORPISO_TRASTERO;

/*****************************************/
/* 7.- Procedimientos y Funciones PL/SQL */
/*****************************************/

/*PROCEDIMIENTOS*/

/*P1*/
CREATE OR REPLACE PROCEDURE PROPIETARIOS(NUM_INMUBLES IN NUMBER, NUM_PROPIETARIOS OUT NUMBER)
    IS
        PARAMETRO_EXCEPTION EXCEPTION;
        NOMBREPROP PERSONA.NOMBRE_PERSONA%TYPE;
        CURSOR NOMBRES IS
            SELECT A.nombre_persona
            FROM PERSONA A, PROPIETARIO B
            WHERE A.DNI_persona=B.DNI_propietario AND B.num_Propiedades=NUM_INMUBLES;
    BEGIN
        IF (NUM_INMUBLES < 1) THEN
            RAISE PARAMETRO_EXCEPTION;
        END IF;
        NUM_PROPIETARIOS := 0;
        OPEN NOMBRES; 
        LOOP
            FETCH NOMBRES INTO NOMBREPROP;
            EXIT WHEN NOMBRES%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(NOMBREPROP);
            NUM_PROPIETARIOS := NUM_PROPIETARIOS + 1;
        END LOOP;  
        DBMS_OUTPUT.PUT_LINE('Propietarios con ' || NUM_INMUBLES || ' inmuebles (' || NOMBRES%ROWCOUNT || ')'); 
       CLOSE NOMBRES;
       
    EXCEPTION
       WHEN PARAMETRO_EXCEPTION THEN
          DBMS_OUTPUT.PUT_LINE('La cantidad de inmuebles debe ser mayor que 0');
       WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);
END Propietarios;
/
show errors

/*P2*/
CREATE OR REPLACE PROCEDURE ACOND_ACT_LOCAL(acond IN LOCAL_COMERCIAL.ACOND_LOCAL%TYPE,
                                            act IN LOCAL_COMERCIAL.ACTIVIDAD_LOCAL%TYPE,
                                            numLocales OUT NUMBER)
    IS    
        CURSOR C_LOCAL_ACOND IS
            SELECT NUM_CATASTRO
            FROM LOCAL_COMERCIAL
            WHERE ACOND_LOCAL = acond
            FOR UPDATE;      
        CURSOR C_LOCAL_ACT IS
            SELECT NUM_CATASTRO
            FROM LOCAL_COMERCIAL
            WHERE ACTIVIDAD_LOCAL = act
            FOR UPDATE; 
        i  LOCAL_COMERCIAL.NUM_CATASTRO%TYPE;   
        NUM_CATASTRO LOCAL_COMERCIAL.NUM_CATASTRO%TYPE; 
        numAcond NUMBER;
        numAct NUMBER; 
        E_NOACOND EXCEPTION;
        E_NOACT EXCEPTION;    
    BEGIN  
        DBMS_OUTPUT.PUT_LINE('Locales con acondicinamiento '|| acond); 
        NumLocales := 0;
        OPEN C_LOCAL_ACOND;
        FETCH C_LOCAL_ACOND INTO NUM_CATASTRO;    
        WHILE C_LOCAL_ACOND%FOUND LOOP
            DBMS_OUTPUT.PUT_LINE(NUM_CATASTRO);
            FETCH C_LOCAL_ACOND INTO NUM_CATASTRO;
        END LOOP;
        numAcond := C_LOCAL_ACOND%ROWCOUNT;     
        CLOSE C_LOCAL_ACOND;
        DBMS_OUTPUT.PUT_LINE('Locales con actividad '|| act);
        OPEN C_LOCAL_ACT;
        FETCH C_LOCAL_ACT INTO NUM_CATASTRO;
        WHILE C_LOCAL_ACT%FOUND LOOP
            DBMS_OUTPUT.PUT_LINE(NUM_CATASTRO);
            FETCH C_LOCAL_ACT INTO NUM_CATASTRO;
            NumLocales := NumLocales + 1;
        END LOOP;
        numAct := C_LOCAL_ACT%ROWCOUNT;    
        CLOSE C_LOCAL_ACT;
        IF (numAcond = 0) THEN
            RAISE E_NOACOND;
        END IF;
        IF (numAct = 0) THEN
            RAISE E_NOACT;
        END IF;
    EXCEPTION
        WHEN E_NOACOND THEN
            DBMS_OUTPUT.PUT_LINE('Excepción: No coincide ningún acondicionamiento');
        WHEN E_NOACT THEN
            DBMS_OUTPUT.PUT_LINE('Excepción: No coincide con ninguna actividad');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);  
END ACOND_ACT_LOCAL;
/
show errors

/*p3*/
CREATE OR REPLACE PROCEDURE EMP_BAJAR_SUELDO(emp_tipo IN VARCHAR, porcentaje IN NUMBER)
    IS
        EXC_NOCOINCIDE EXCEPTION;
        CURSOR C_EMP IS
            SELECT *
            FROM EMPLEADO
            WHERE tipo_contrato LIKE emp_tipo AND salario > 1100
            FOR UPDATE;
        regEmp EMPLEADO%ROWTYPE;
        cont NUMBER;
    BEGIN
        cont := 0;
        FOR regEmp IN C_EMP LOOP
            DBMS_OUTPUT.PUT('Empleado: ' || regEmp.DNI_empleado || '; Salario actual: ' || regEmp.Salario);
            UPDATE EMPLEADO SET SALARIO = SALARIO*(1 - porcentaje)
            WHERE CURRENT OF C_EMP; 
            DBMS_OUTPUT.PUT_LINE('; Salario nuevo: ' || regEmp.Salario);
            cont := cont + 1;
        END LOOP;
        IF cont = 0 THEN RAISE EXC_NOCOINCIDE;
        END IF; 
        DBMS_OUTPUT.PUT_LINE(cont || ' SALARIOS HAN SIDO ACTUALIZADOS');  
    EXCEPTION
        WHEN EXC_NOCOINCIDE THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: El tipo de contrato introducido no coincide con ninguno de los existentes.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Codigo: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SUBSTR(SQLERRM, 11,100));
END EMP_BAJAR_SUELDO;
/
show errors

/*p4*/
CREATE OR REPLACE PROCEDURE APLICAR_DESCUENTO(descuento IN NUMBER)
    IS
        PARAMETRO_MENOR_EXCEPTION EXCEPTION;
        PARAMETRO_MAYOR_EXCEPTION EXCEPTION;
        CURSOR C_CONTRATO IS
            SELECT *
            FROM CONTRATO
            FOR UPDATE;
        RegContrato CONTRATO%ROWTYPE;
    BEGIN
    IF (descuento < 0)THEN
            RAISE PARAMETRO_MENOR_EXCEPTION;
        END IF;
    IF (descuento >= 100)THEN
            RAISE PARAMETRO_MAYOR_EXCEPTION;
        END IF;
    FOR RegContrato IN C_CONTRATO LOOP
        DBMS_OUTPUT.PUT('ID contrato: ' || RegContrato.ID_contrato);
        DBMS_OUTPUT.PUT_LINE('; Precio original: ' || RegContrato.importe);
        UPDATE CONTRATO SET importe = importe*((100-descuento)/100) WHERE CURRENT OF C_CONTRATO;
    END LOOP;
    FOR RegContrato IN C_CONTRATO LOOP
        DBMS_OUTPUT.PUT('ID contrato: ' || RegContrato.ID_contrato);
        DBMS_OUTPUT.PUT_LINE('; Precio actual: ' || RegContrato.importe);
    END LOOP;
    EXCEPTION
       WHEN PARAMETRO_MENOR_EXCEPTION THEN
          DBMS_OUTPUT.PUT_LINE('El descuento debe ser mayor que 0');
        WHEN PARAMETRO_MAYOR_EXCEPTION THEN
          DBMS_OUTPUT.PUT_LINE('El descuento debe ser menor que 100');
       WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);
END APLICAR_DESCUENTO;
/
show errors

/*p5*/
CREATE OR REPLACE PROCEDURE ACTUALIZAR_PROPIETARIO(DNI IN PROPIETARIO.DNI_propietario%TYPE, numProp OUT NUMBER)
    IS
        CURSOR C_INMUEBLE IS
            SELECT COUNT(num_catastro)
            FROM INMUEBLE
            WHERE DNI_propietario = DNI;
        DNI_EXCEPTION EXCEPTION;
    BEGIN
        OPEN C_INMUEBLE;
        FETCH C_INMUEBLE INTO numProp;
        IF C_INMUEBLE%NOTFOUND THEN 
            RAISE DNI_EXCEPTION;
        END IF;
        UPDATE PROPIETARIO SET num_propiedades = numProp
            WHERE DNI_propietario = DNI;
        CLOSE C_INMUEBLE;
        DBMS_OUTPUT.PUT_LINE('Número de propiedades: ' || numProp);
    EXCEPTION
        WHEN DNI_EXCEPTION THEN
            DBMS_OUTPUT.PUT_LINE('No se han encontrado al propietario con DNI ' || DNI);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Codigo: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SUBSTR(SQLERRM, 11,100));
END ACTUALIZAR_PROPIETARIO;
/
show errors

/*FUNCIONES*/
/*f1*/
CREATE OR REPLACE FUNCTION CASAS_POR_PLANTAS(PLANTAS IN NUMBER)
    RETURN NUMBER
    IS
       numCasas NUMBER;
       SINCASAS_EXCEPTION EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO numCasas
        FROM CASA 
        WHERE plantas_casa=PLANTAS;
        IF numCasas = 0 THEN 
            RAISE SINCASAS_EXCEPTION;
        END IF;
        RETURN numCasas;
    EXCEPTION
        WHEN SINCASAS_EXCEPTION THEN
            DBMS_OUTPUT.PUT_LINE('No se han encontrado casas con ' || PLANTAS || ' plantas.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Codigo: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SUBSTR(SQLERRM, 11,100));   
END CASAS_POR_PLANTAS;
/
show errors

/*f2*/
CREATE OR REPLACE FUNCTION COUNT_ACOND(acond IN LOCAL_COMERCIAL.ACOND_LOCAL%TYPE)
    RETURN NUMBER
    IS
    toRet NUMBER;
    E_NOACOND EXCEPTION;    
    BEGIN    
        SELECT COUNT(*) INTO toRet
        FROM LOCAL_COMERCIAL
        WHERE ACOND_LOCAL = acond;                 
        IF(toRet = 0)THEN
            RAISE E_NOACOND;
        END IF;     
        RETURN toRet;
    EXCEPTION
        WHEN E_NOACOND THEN
            DBMS_OUTPUT.PUT_LINE('Excepción: No coincide ningún acondicionamiento');
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);       
END COUNT_ACOND;   
/
show errors

/*f3*/
CREATE OR REPLACE FUNCTION AGENTE_POR_ZONA(zona IN VARCHAR)
    RETURN NUMBER
    IS
        num_agentes_zona NUMBER;
        NO_AGENTES_EXCEPTION EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO num_agentes_zona
        FROM AGENTE
        WHERE zona_ciudad = zona;
	IF num_agentes_zona = 0 THEN
		RAISE NO_AGENTES_EXCEPTION;
	END IF;
        RETURN num_agentes_zona;
    EXCEPTION
        WHEN NO_AGENTES_EXCEPTION THEN
            DBMS_OUTPUT.PUT_LINE('No se han encontrado agentes en la zona indicada (' || zona || ')');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Codigo: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SUBSTR(SQLERRM, 11,100));   
END AGENTE_POR_ZONA;
/
show errors

/*f4*/
CREATE OR REPLACE FUNCTION NUM_VENTAS_FECHA(fecha_ini IN DATE, fecha_fin IN DATE)
RETURN NUMBER
IS
    BADFORMAT_EXCEPTION EXCEPTION;
    num_ventas NUMBER;
BEGIN
    SELECT COUNT(*) INTO num_ventas
    FROM FIRMA
    WHERE fecha_firma>=fecha_ini AND fecha_firma<=fecha_fin;
    RETURN num_ventas;
    EXCEPTION
        WHEN BADFORMAT_EXCEPTION THEN
            DBMS_OUTPUT.PUT_LINE('El formato de fecha es incorrecto');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Codigo: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SUBSTR(SQLERRM, 11,100));   
END NUM_VENTAS_FECHA;
/
show errors

/*f5*/
/*
CREATE OR REPLACE FUNCTION DEVOLVER_FECHA
RETURN TIME
IS
BEGIN
    SELECT CONVERT (date, SYSDATETIME())  
    ,CONVERT (date, SYSDATETIMEOFFSET())  
    ,CONVERT (date, SYSUTCDATETIME())  
    ,CONVERT (date, CURRENT_TIMESTAMP)  
    ,CONVERT (date, GETDATE())  
    ,CONVERT (date, GETUTCDATE()) INTO fecha_hoy;
    RETURN fecha_hoy;
END DEVOLVER_FECHA;
/
show errors
*/

/********************************************************/
/* 8.- Bloque para prueba de Procedimientos y Funciones */
/********************************************************/

SET SERVEROUTPUT ON
DECLARE
   toRet NUMBER;
BEGIN
   DBMS_OUTPUT.NEW_LINE;
--procedimientos
   BEGIN
-- PROPIETARIOS
      DBMS_OUTPUT.PUT_LINE('======>INICIO PROCEDIMIENTO: PROPIETARIOS');
      PROPIETARIOS(3, toRet);
      DBMS_OUTPUT.PUT_LINE('Numero de propietarios con 3 inmuebles: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN PROCEDIMIENTO: PROPIETARIOS');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
-- ACOND_ACT_LOCAL
      DBMS_OUTPUT.PUT_LINE('======>INICIO PROCEDIMIENTO: ACOND_ACT_LOCAL');
      ACOND_ACT_LOCAL('VACIO', 'ALMACEN', toRet);
      DBMS_OUTPUT.PUT_LINE('Numero de locales: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN PROCEDIMIENTO: ACOND_ACT_LOCAL');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
-- EMP_BAJAR_SUELDO
      DBMS_OUTPUT.PUT_LINE('======>INICIO PROCEDIMIENTO: EMP_BAJAR_SUELDO');
      EMP_BAJAR_SUELDO('temporal', 10);
      DBMS_OUTPUT.PUT_LINE('======>FIN PROCEDIMIENTO: EMP_BAJAR_SUELDO');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
-- APLICAR_DESCUENTO
      DBMS_OUTPUT.PUT_LINE('======>INICIO PROCEDIMIENTO: APLICAR_DESCUENTO');
      APLICAR_DESCUENTO(10);
      DBMS_OUTPUT.PUT_LINE('======>FIN PROCEDIMIENTO: APLICAR_DESCUENTO');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
-- ACTUALIZAR_PROPIETARIO
      DBMS_OUTPUT.PUT_LINE('======>INICIO PROCEDIMIENTO: ACTUALIZAR_PROPIETARIO');
      ACTUALIZAR_PROPIETARIO('00734219J', toRet);
      DBMS_OUTPUT.PUT_LINE('Numero de propiedades del propietario 00734219J: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN PROCEDIMIENTO: ACTUALIZAR_PROPIETARIO');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
--funciones

   BEGIN
-- CASAS_POR_PLANTAS
      DBMS_OUTPUT.PUT_LINE('======>INICIO FUNCIÓN: CASAS_POR_PLANTAS');
      toRet := CASAS_POR_PLANTAS(2);
      DBMS_OUTPUT.PUT_LINE('Casas con 2 plantas: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN FUNCIÓN: CASAS_POR_PLANTAS');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
   -- COUNT_ACOND
      DBMS_OUTPUT.PUT_LINE('======>INICIO FUNCIÓN: COUNT_ACOND');
      toRet := COUNT_ACOND('VACIO');
      DBMS_OUTPUT.PUT_LINE('Locales vacios: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN FUNCIÓN: COUNT_ACOND');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
   -- AGENTE_POR_ZONA
      DBMS_OUTPUT.PUT_LINE('======>INICIO FUNCIÓN: AGENTE_POR_ZONA');
      toRet := AGENTE_POR_ZONA('centro');
      DBMS_OUTPUT.PUT_LINE('Agentes asignados a la zona centro: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN FUNCIÓN: AGENTE_POR_ZONA');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;
   
   BEGIN
   -- NUM_VENTAS_FECHA
      DBMS_OUTPUT.PUT_LINE('======>INICIO FUNCIÓN: NUM_VENTAS_FECHA');
      toRet := NUM_VENTAS_FECHA('2020-01-01','2020-10-01');
      DBMS_OUTPUT.PUT_LINE('Número de ventas entre enero y octubre de 2020: ' || toRet);
      DBMS_OUTPUT.PUT_LINE('======>FIN FUNCIÓN: NUM_VENTAS_FECHA');
      DBMS_OUTPUT.NEW_LINE;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN]');
         DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
         DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
   END;

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('[EXCEPCIÓN NO TRATADA EN EL BLOQUE PRINCIPAL]');
      DBMS_OUTPUT.PUT_LINE('[Código]: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('[Mensaje]: ' || SUBSTR(SQLERRM, 11, 100));
END;
/