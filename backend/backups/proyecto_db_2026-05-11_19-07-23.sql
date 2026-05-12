--
-- PostgreSQL database dump
--

\restrict 4zzmaiKJh7syrJ95Zv229Rr4LEpSiiMa1x4ErbVzweXqmq35uIos7ofGHjiY07X

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: budgets_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.budgets_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'VOTING_CLOSED',
    'COMPLETED',
    'ARCHIVED'
);


--
-- Name: issues_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.issues_status_enum AS ENUM (
    'OPEN',
    'IN_REVIEW',
    'RESOLVED',
    'CLOSED'
);


--
-- Name: proposal_comments_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.proposal_comments_status_enum AS ENUM (
    'VISIBLE',
    'HIDDEN'
);


--
-- Name: questions_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.questions_type_enum AS ENUM (
    'TEXT',
    'MULTIPLE_CHOICE',
    'SINGLE_CHOICE',
    'RATING',
    'CHECKBOX',
    'TEXTAREA'
);


--
-- Name: surveys_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.surveys_status_enum AS ENUM (
    'DRAFT',
    'ACTIVE',
    'CLOSED',
    'ARCHIVED'
);


--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.users_role_enum AS ENUM (
    'CITIZEN',
    'ADMIN',
    'MODERATOR'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userId" uuid,
    action character varying NOT NULL,
    "entityType" character varying NOT NULL,
    "entityId" character varying,
    changes json,
    "ipAddress" character varying,
    "userAgent" character varying,
    "statusCode" integer DEFAULT 200 NOT NULL,
    "errorMessage" character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: budget_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "budgetId" uuid NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    "estimatedCost" numeric(12,2) NOT NULL,
    "voteCount" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


--
-- Name: budget_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budget_votes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "budgetId" uuid NOT NULL,
    "itemId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    status public.budgets_status_enum DEFAULT 'DRAFT'::public.budgets_status_enum NOT NULL,
    "totalAmount" numeric(12,2) NOT NULL,
    "allocatedAmount" numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    "createdBy" uuid,
    "participantsCount" integer DEFAULT 0 NOT NULL,
    "startDate" timestamp without time zone,
    "endDate" timestamp without time zone,
    "allowMultipleVotes" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    category character varying NOT NULL,
    status public.issues_status_enum DEFAULT 'OPEN'::public.issues_status_enum NOT NULL,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(10,7) NOT NULL,
    address character varying,
    "createdBy" uuid,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: proposal_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposal_comments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "proposalId" uuid NOT NULL,
    "userId" uuid,
    content text NOT NULL,
    status public.proposal_comments_status_enum DEFAULT 'VISIBLE'::public.proposal_comments_status_enum NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proposals (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    votes integer DEFAULT 0 NOT NULL,
    category character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "votedBy" text DEFAULT '[]'::text NOT NULL
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "surveyId" uuid NOT NULL,
    text character varying NOT NULL,
    type public.questions_type_enum DEFAULT 'TEXT'::public.questions_type_enum NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    "isRequired" boolean DEFAULT true NOT NULL,
    options json,
    "conditionalLogic" json,
    "isConditional" boolean DEFAULT false NOT NULL
);


--
-- Name: survey_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_responses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "surveyId" uuid NOT NULL,
    "questionId" uuid NOT NULL,
    "userId" uuid NOT NULL,
    response json NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surveys (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    status public.surveys_status_enum DEFAULT 'DRAFT'::public.surveys_status_enum NOT NULL,
    "createdBy" uuid,
    "responseCount" integer DEFAULT 0 NOT NULL,
    "startDate" timestamp without time zone,
    "endDate" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "firstName" character varying NOT NULL,
    "lastName" character varying NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    role public.users_role_enum DEFAULT 'CITIZEN'::public.users_role_enum NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, "userId", action, "entityType", "entityId", changes, "ipAddress", "userAgent", "statusCode", "errorMessage", "createdAt") FROM stdin;
85e01dba-85b6-4199-9b6e-ee2cfcc07a5e	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	401	Credenciales inválidas	2026-05-07 23:22:36.086209
4e0ac19c-a3f9-4fd4-ada1-e7215b515708	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	401	Credenciales inválidas	2026-05-07 23:22:38.913189
3d7c48c0-36d0-4803-a1f3-8233567ac828	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	401	Credenciales inválidas	2026-05-07 23:23:21.557844
9eca726a-b0c0-4328-953c-6daaa65e0b01	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	401	Credenciales inválidas	2026-05-07 23:23:22.173668
37e39118-7ea2-48be-a111-282be15523f2	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	401	Credenciales inválidas	2026-05-07 23:23:22.538628
ce0e2516-1830-49bd-a30b-156ddbad9cd0	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login","duration":120,"responseSize":392}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.157361
9ee00ee7-bbdc-4c9c-8725-8b4582b38ce8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":21,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.215847
bbbc7537-5509-41c8-8996-9791f107d829	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":107,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.308308
ac93346b-b5c2-468e-a791-580e236886b8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":134,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.332232
f9fb0112-bdd3-43e3-9f4e-bace889d8ad7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":145,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.349682
9aa2a05d-96bb-411f-bfbe-088d478c28c4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":200,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:24:43.407912
8a1647a9-530f-44a1-a3ad-41e303764adc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":230,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:01.781663
6576071b-cb6b-4bf1-8905-65014a8a7dab	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":83,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:01.645688
ab5d1e54-e3f4-4966-b52b-eab493882a24	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":297,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:01.864978
7d87738d-659a-483e-b100-11b26c898a76	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":947,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:02.517024
6471b8b4-8499-4d74-bdd0-7b67e13039a2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":1068,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:02.611829
0ebcfbe9-abbc-4f77-b23b-3e82516502f7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":4,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:03.354556
38472949-6e88-4e58-a66f-508c64820229	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:03.359924
e7b08e4f-5329-451a-9aa3-59b26bbf227f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:03.379221
9b46e04f-77c4-47bb-ab80-de64a074a045	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":5,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:03.363809
65a26f1a-1458-4b17-81a3-ce17e7749f1f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":9,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:03.403448
1f26dadb-fed9-4561-9d0d-f7e246f56bb0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":4,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:06.522284
46313de8-d422-4b75-8bf1-452a1ecbee8b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:06.526307
80e29b16-f9f9-479e-a282-cfb900edcda9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":1,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:06.542546
3515aca8-9c2c-4b0a-9736-b333f86426b5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":1,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:06.533185
fdda9b31-ee97-4e1d-8479-c957e421af7a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":12,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:06.566969
60dafdd5-01e0-451a-a3b5-db72a0581a69	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":159,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:30.455284
8d1986d8-ae1f-490c-9b16-f7ed76f869de	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":253,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:30.551508
4b7bb1c6-b646-4e41-bbc9-1f3c4b6f5ce9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":167,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:30.468514
69b76575-055e-492a-a0c0-9d3bdad36d4f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":306,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:30.609649
71dd77b8-b4b9-4be7-a827-49a9181d06b4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":352,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:30.65908
f68eb2d4-e40b-4959-8787-df3181030ea2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":103,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:54.137295
1e04c467-64bd-4bfd-b7c0-4f1254ce33a2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":80,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:54.116609
417fe509-8952-4687-b273-8ba32b8f450f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":159,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:54.191308
a699c440-0e4d-4791-bb7b-f1f190601855	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":182,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:54.229343
924ebf0d-649d-4725-94d0-b9c5b24791e7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":208,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:54.251381
e48ea781-94b6-4ccb-a27c-2322240c93e0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:58.796961
08f0d35d-1997-42b4-a6ad-efe23c3a19e0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:58.796273
cfc74b9f-1199-42a3-bad0-9970197d650a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:58.799737
5f35d409-ae85-4093-bbec-dc5aa0f0df18	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":1,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:58.781104
1ac549f0-c523-46bb-b11e-9320c02c1a79	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":64,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:49:58.858809
1c0074f4-367f-4b1f-a2ac-a92d420a9f67	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":9,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:50:03.128778
1b69d7b2-8ffc-4603-bbd1-3f91d1cf3a4e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":5,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:50:07.51466
03f06c0d-7f93-4e7e-9cd6-bab1e30e4cad	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":170,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:03.253216
2f2007a7-5381-4e04-9b5d-bef5c2f7d6e9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":163,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:03.25128
fd2d00c5-9486-41d0-ad7a-26f06df5ebe4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":116,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:03.198716
5b275908-fd34-461b-9e2a-22dce2a6ca4e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":307,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:03.398112
e9f73402-5caa-45fd-8b27-b024b505c74f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":336,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:03.402821
bec0713f-96bb-4a59-b190-8b16f80b7ff9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":12,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:04.413284
9d7a47a5-8f49-421d-bae6-d15da4e023b6	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login","duration":110,"responseSize":392}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.397204
f2094f66-c3da-4b84-b1e0-6033aff21ac5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.430816
4952068f-5e24-4d50-b6f7-b39e4539d14e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":83,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.510137
cde3f6aa-97ae-4f9d-aa61-3a54f9e5b199	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":100,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.533928
d4015546-5def-4932-a5b2-7a9419ffc363	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":142,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.571012
ad3d1fa5-cdd3-49ad-941f-9e68a8103b54	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":181,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:35.616356
faf36e60-784f-4cd3-b46d-457aa5c382cb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":13,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:37.658667
aa29ee9a-6186-4d52-b019-b3f0ac688d85	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:39.713538
20b80396-ab99-4770-9770-4c7e139ff5cd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:39.716143
af29d7a2-dbcc-48f3-bff7-890f2aea28e2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:39.716725
c4c92cc8-6dcd-4020-b679-a3a8afe82a3c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:39.714816
b4567c17-d39e-4d3b-97e5-6c3f96411181	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":25,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:54:39.73644
950b48aa-8cc3-49fd-a92f-6077aa15a44d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Property "user" was not found in "Proposal". Make sure your query is correct.	2026-05-07 23:54:44.123962
cbce4067-03a9-4e46-b8ee-e55d5ca1d823	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Property "user" was not found in "Proposal". Make sure your query is correct.	2026-05-07 23:54:45.932867
742283f9-a320-4ecd-9031-f4093f132c38	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":77,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:02.285167
86efe14e-6562-4859-8540-563b78572bd1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":92,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:02.304016
e00642cf-97da-44e1-87ef-f16ce177ed27	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":146,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:02.356112
0148053e-caff-4f46-9b8a-5d5dac19bd0b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":228,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:02.442294
09c6e083-b680-4718-97f7-724acbd64774	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":286,"responseSize":130}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:02.502958
5e3d7f09-c16e-4893-85ed-f1197846dfa1	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	\N	{"method":"POST","path":"/api/proposals","duration":203,"responseSize":208}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.63967
9449dd28-6f9c-4b26-be6e-61d6ef5ec23e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.776651
b2dff03a-2adb-4299-a166-b5bb56e08bd6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":122,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.779754
bb7d782a-164f-4c4c-af28-2ca27c9ad567	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":74,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.725785
4c5aa85a-adeb-4204-a493-33df71fc6b5b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":85,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.738141
8465a1e8-46fe-431c-a4e4-3074a39702f4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":151,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.807305
0d41f970-202c-48b8-8180-3a18c9f01888	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":184,"responseSize":338}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:19.843154
1f8292a8-3520-42ea-8f18-587bb176806b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":10,"responseSize":338}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:25.172919
da515b49-b658-4150-b97c-76eaa33e577e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":8,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.821982
e0b1523f-6937-4f55-8919-c05e6253abcb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.824284
884ce0a3-3578-465e-8f57-394cc6cb510e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":5,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.824988
be246aee-9d78-42f8-a485-c3d09833d8ac	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.826116
2ea4a816-c890-4da3-bae4-97ecffef6a71	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":20,"responseSize":338}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.830928
97bf8541-02ca-495f-9361-292c15b7b8fe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:55:28.882999
33faba3b-eafb-4033-8600-b60d111324ca	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Property "user" was not found in "Proposal". Make sure your query is correct.	2026-05-07 23:55:30.728839
430ab9c5-1f30-4024-834d-a51ee050aafb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Property "user" was not found in "Proposal". Make sure your query is correct.	2026-05-07 23:55:31.821548
018621d3-fec1-4d04-9396-1cc0b2eea3e4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":166,"responseSize":338}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:02.258064
700b05b6-3e73-4c2d-a96c-bf7d72dc8f7a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":24,"responseSize":338}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.524338
c5edf2cb-3d74-4bbc-8199-474e7906c10e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":101,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.612798
2bf4dfb0-0543-47b1-952d-98677905ae83	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":96,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.611776
835ca0d0-15c0-4200-ad23-427dcb3eb165	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":128,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.636423
5cc2c439-2632-4a4f-8da1-f0702e568d19	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":145,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.649456
c3d987ce-82e4-41e3-bced-42ced78c2ea2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-07 23:59:04.692186
b1cf0c8a-a91f-4d78-80fb-a5b41895925f	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	\N	{"method":"POST","path":"/api/proposals","duration":74,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.619138
d697a9ce-8be0-455e-925a-ab963ab02f19	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":81,"responseSize":416}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.712147
5531502b-f33d-4eda-964a-ab89ba0c6b27	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":108,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.744152
ef28aafe-589d-47f2-8f27-5fa4e9e92e64	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":115,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.756059
c09c7e10-b8e6-4b9d-b521-8d69426a0420	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.815766
69fa854d-be60-470a-8ab0-635489a29c55	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":172,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.809811
826350a3-0d46-4219-b64c-719bf629cb66	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.821752
215643d0-4b89-4dfe-87b3-425d28e3b159	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":208,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:42.852693
83d06c77-ddeb-4d6c-9109-a45afbe1094b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":10,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:44.907115
2c447ea3-d42e-4c55-b4c3-a6ec4f8b8631	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":12,"responseSize":416}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.15328
8335ccf6-9491-4454-84e4-743a8ac23d52	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.154729
cff7ab9c-9fc8-4cc8-9809-006586c68049	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.15741
e1a33b6d-56b9-41dc-8304-0ee8c38b25c7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.155187
29fbb1af-7758-4809-8dde-d2211f45c93c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":19,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.169751
fc3ecf57-c7d1-4f4d-a246-b691f6e7c547	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.197355
7760819c-9ec8-4b38-b25d-496ef879d782	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:14:48.199014
0008f6e8-f5f2-461a-af7a-9f3210bcf69e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":309,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.439488
875f13b8-52ce-4746-8895-f5fdc154ebaa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":413,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.54006
bb6fdde5-7940-4971-a283-853784773056	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":533,"responseSize":416}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.657615
c0975589-b7fb-4c96-b706-f26f1ee51d9f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":569,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.70398
efd1d168-424b-4501-a4a9-6fad5420d0e2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":593,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.727256
2bf40d28-c65a-4e97-bf54-5013fbbf4b35	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.751248
cfda61f1-e2c1-43e4-94b8-626b8bbab8f4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:15:59.753458
d0da770a-b426-47e9-9865-2564b3caf87d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":180,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:13.673051
931dbde8-a05d-44ad-9ff5-3ea147748ba5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":13,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:19.691541
f67a74d6-a247-4acb-8103-a7b44db3d2f4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":11,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:28.110534
31e3d5fc-a351-4471-a657-23ab35f4b2dd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":11,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:37.078732
3d9cc20e-5c60-45c3-8dca-bb9dac8bb094	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":5,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:39.523586
699459d6-773f-4c21-b530-a069b37d166c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":3,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:44.510244
f6da73b8-aa09-40b0-9727-09a23fc1af35	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":4,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:16:54.069518
1c5734f5-1c9d-49cb-b999-d2122f85102b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":223,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:17:43.744938
f6b1b7c8-7589-4e80-b565-c711be05afff	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":14,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:17:52.051157
cfdfe02c-cb17-4873-b479-2bceaf31fea9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":13,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:18:01.592144
dcb404be-2a70-4c67-99a9-05ff5570dba1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":4,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:18:07.239279
d045e607-c786-4d4c-8f4d-dda63b00532b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Property "user" was not found in "Proposal". Make sure your query is correct.	2026-05-08 00:18:14.010031
3c869c4a-e068-4987-9b2c-a74db7ff02bc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Converting circular structure to JSON\n    --> starting at object with constructor 'Socket'\n    |     property 'parser' -> object with constructor 'HTTPParser'\n    --- property 'socket' closes the circle	2026-05-08 00:22:45.911817
f8e68f0d-d6f5-476a-9607-b8527f402cfc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Converting circular structure to JSON\n    --> starting at object with constructor 'Socket'\n    |     property 'parser' -> object with constructor 'HTTPParser'\n    --- property 'socket' closes the circle	2026-05-08 00:24:59.373176
15ac0187-c5e7-48f7-903d-c602513ac576	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/proposals"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	500	Converting circular structure to JSON\n    --> starting at object with constructor 'Socket'\n    |     property 'parser' -> object with constructor 'HTTPParser'\n    --- property 'socket' closes the circle	2026-05-08 00:25:07.48078
a9b1401b-0c49-44d5-9218-78e88a6507bd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":294,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:31:41.295388
6e5e4883-59db-45f6-9823-67b7889ddd3e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":16,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:31:47.046867
ec65b449-188b-4b22-a4d7-f6b2e84d8d9c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":203,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:04.967815
46110ab2-a1ca-4af8-8bae-c2751961f6e8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":263,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.025496
8dcb8596-215e-4a1b-8a67-afbc1109bc33	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":348,"responseSize":416}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.106197
b8f6a9ba-ce87-4d37-ad35-e4fad9a03f2a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.171422
85791868-eeeb-4299-8ad9-ed00cd1097c4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.169533
2ae574e5-231a-4cc8-8047-a77159684605	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":391,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.181818
5862172b-de8f-4eb9-b5fc-c3f353faa484	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":436,"responseSize":544}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:05.230589
736afae4-e24a-4005-919a-68ed0b232e1d	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	\N	{"method":"POST","path":"/api/proposals","duration":122,"responseSize":246}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.533957
7c469430-1cec-4734-8ad5-9a4ad0ac7299	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":175,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.733974
d9141d2c-1ca1-4ca0-9be2-b8d4bf064d66	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":203,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.768065
cf23ccb4-d43b-43fa-b37d-b20b56f8a28f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":227,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.788556
e2c97031-d204-4f00-a957-8105d48419bd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.805336
5304635e-8f28-4e3a-96e8-04e491ebb16a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.811641
d005bddd-0ef7-43b4-9356-a47ad4adafcf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":254,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.828417
6b3d8779-45de-4628-801e-0cd3247d8695	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":51,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.851521
db2f91c4-3068-49a0-b5c0-f384659c3799	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":328,"responseSize":791}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:18.897468
c2b506d7-4332-42f8-8464-4b242d731bda	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"POST","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":13,"responseSize":262}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:28.114584
5e14b3bf-0652-4561-aaaa-1e0856fcbab1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":14,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.087626
1327ab31-7efc-4f61-a37b-c8eb745255ca	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":6,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.113542
d856a60e-f679-43af-812b-3c45622d2dcf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":2,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.123779
d479d604-7fba-45c2-99dd-8917b017ce5d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.151898
84d14483-e903-45bd-b2b6-5167aab9436a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":137,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.218822
4fb8c861-6f63-4a40-a412-85a648c7085a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":173,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.252156
2348f1e2-f4d3-4850-afab-a6e73e30925e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":245,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.322445
fc659c7a-4ca9-447c-8ade-1db58f2f7701	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":332,"responseSize":791}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.417124
42a8a78c-7202-4344-8ed7-3ee8b74d58c3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":11,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.776886
3848a8be-08b1-4e3f-8c21-6f5280335983	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.777111
33383978-2b27-41ce-907f-c395b1de4ab4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.782997
2f12f7b1-dc53-4946-af74-b1f113cd249c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.77705
7234f965-6010-4a6f-893f-4b3da0ffed8f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":23,"responseSize":791}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.797027
1a9e0ab5-cabc-4c3e-85b0-82ac76052719	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":11,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.842728
5df997ce-3d7b-455a-b1ab-34f177212e8f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.847927
eeef8d67-a98a-4292-9711-ea0fe61ccd0f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":5,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:32.864956
44ceb56e-d201-46b3-a182-883c1914fd66	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":294,"responseSize":791}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:34:45.220947
f07e7d83-f33f-4feb-94b6-df901c0c2fdc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":290,"responseSize":791}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:35:03.376889
824006ad-ff07-4bca-9a2b-0178a4e100bc	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":11,"responseSize":293}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:35:08.508454
55b4fce3-93f6-4e4f-8d5b-00501de1b47f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":14,"responseSize":820}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:35:09.881208
eca7972a-8ae4-4e4f-8ed3-604c51dbd975	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	BUDGETS	\N	{"method":"POST","path":"/api/budgets","duration":122,"responseSize":682}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:35:24.095426
aa9f86dc-763e-40db-964e-a78d8385d5d2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":178,"responseSize":850}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:35:26.810488
75c30917-05e4-4b38-ae43-65820c236e0c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":239,"responseSize":850}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:44:51.004918
66da9d0f-0526-4b69-827a-d704edf53043	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":9,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.65846
cd5c056d-ddb1-4572-ae0e-a084d9afaa4c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":9,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.659781
8dfb1488-4acf-4a6a-a41c-77b45f1f6cb4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.670679
4800e746-7fe7-41d3-9f70-43d9a47938b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":7,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.661712
88eed288-c9f5-455f-b3ac-2bd35a2eea18	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":8,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.769465
ae5ede0d-3eff-48ba-b2b2-b6eb21872c67	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.773493
ce815d69-8500-4cc4-953c-aea050fb2a01	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.774323
dab18df9-aa5c-4877-ad98-003d27d9d416	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":221,"responseSize":850}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:00.884334
1872f7c2-a3e5-4500-837d-76551c4053c8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":2,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.580547
bf00220e-f81d-4b16-94aa-92ac311ac259	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":8,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.603376
0e9d63ed-38e9-4896-b841-6fdfaade4abf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":14,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.664509
510ad361-d738-4b61-925d-e91ae4643e18	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":14,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.669747
027d7148-a9bf-410d-ad7c-c9bb9b3ea50d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":14,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.671742
6da80a9d-2a0f-474e-af73-5249765e0689	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":253,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.845578
e9cd1744-4268-4818-af8e-5a34b554f549	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":271,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.85904
9d7414bc-bdbe-4ced-9c0f-b1ccb0a930b0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":353,"responseSize":850}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:01.950857
c076f5af-b2c6-46b1-af8b-0c86256f973b	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login","duration":113,"responseSize":392}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.03115
fd67ddaf-7cbd-42f3-8ceb-30ac8bf6f011	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":11,"responseSize":663}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.083645
7cd8f24a-8ade-4fe6-bb94-3876a24a62d8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":6,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.142269
fd0f992e-e8ae-45e6-9e45-fea3fe8854a0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":2,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.157408
87425316-ac83-443d-b7ec-aeb0e285d09a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.181072
97e9a0dd-c163-499a-bf07-6540b05b2e57	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":168,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.242231
d71f5eef-62c8-411c-9665-a67aa7aab5fa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":214,"responseSize":850}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.292632
3d7ed683-4c7b-4790-9d3c-8cab6fe9c11f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":230,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.306199
369311c5-3787-4e3d-a873-b702c51da331	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":242,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:16.323062
4ee74916-fe38-4b09-a450-389c264da22e	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	\N	{"method":"POST","path":"/api/proposals","duration":14,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.151984
96ac3150-bbcd-470f-956a-7a64e695220c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":6,"responseSize":860}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.169011
e824e73d-4bfa-41a2-b174-f5aff2db7d57	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.178073
0a2e516d-d9d7-417a-888e-129326e67152	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":11,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.179708
e2ed095c-01f0-4b57-a48d-dff319b73e68	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":9,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.182194
3090143a-9e76-473a-8d2f-1e41a5b802fd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.213685
45c0514b-5e44-46b4-beee-45eea549b9a8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.226042
2e9ffef5-b45a-4836-9817-182ae185bb46	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":45,"responseSize":1047}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.221959
3c4a8c73-160a-469d-8dc6-c40cbbe024b1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.230498
d6da8151-8be1-4050-b4e8-0897ebf6d3e5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":19,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:45:25.233706
1a2e565c-d5af-4baa-bf33-1de9bee3ecfe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":132,"responseSize":860}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:49.996301
eaf2d5ba-a84c-4d08-9397-50d21ad48e8e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":187,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.060605
ce56e535-3d45-4c1d-b558-eaca0b245580	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":203,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.075102
8d2d320a-ea84-4042-a047-115c39cc8883	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":8,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.093713
80a907f2-f560-462d-82c6-624907e656f8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":123,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:49.992971
d5ffffed-4778-4dc8-8f97-d79a810ee2ed	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.103925
8d7457ba-8b1e-45b9-a270-6e594a9410e9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":245,"responseSize":1047}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.120035
2b4a050a-10d1-488e-a103-394907796709	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":35,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.122514
2ecd319c-b7ea-4072-a3b9-27b3b1ea5ef6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":38,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:50.121818
ce257a44-7aa7-43e4-9f21-7d774d5a43ad	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.275686
0d52784f-091b-4c03-b645-a96fc4d8ae2a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":15,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.357706
7d74f86f-5926-4cc7-9759-ba9ddfa140fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":11,"responseSize":860}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.274805
4aa26619-6977-4611-bd36-293b324dd42b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":9,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.278418
ff0eb2fa-1131-4151-bade-70b920a21c73	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.365053
1129075c-d46e-4181-967b-60a1d5f307b6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":5,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.276471
eb1471ea-96a5-44d7-8d61-4fdaf8b4282e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":25,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.363762
81496b47-607b-45cd-ab8f-2c5289cf4f5c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":40,"responseSize":1047}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.322305
5b9188ef-f3a5-41ca-8e01-d4bc5d414912	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":26,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:46:53.360792
273c7dba-afaf-4543-b72b-9c4d06888428	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":150,"responseSize":860}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.486733
721cca38-85ad-4f78-8031-4b8de4195c33	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":145,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.487732
abcc40ab-e94c-4342-8896-756b5265b249	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.571343
391b9c46-c6b7-4701-9478-d45d83c35282	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":8,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.570017
363a8af7-5fe4-4aee-9895-eedaa0b34098	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":238,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.579053
172299d3-d9b4-4101-8841-153ce86f5abe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":2,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.588394
d161f6f9-d45d-4efb-84cb-c27d8bed72f1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":216,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.555343
7e7f68da-dc84-4679-b95a-556eb7617691	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.569089
77e8d4c5-e5ca-4bf1-9272-39e2fc094ee0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":266,"responseSize":1047}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:11.61107
9779f191-8513-4854-ae9f-bf13ddc8031d	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	\N	{"method":"POST","path":"/api/proposals","duration":7,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.24771
e56ea6b4-5716-4668-839e-01c218a43f4c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":8,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.265154
5d644bed-9a74-4b02-a1f3-e5eeb15bea83	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.276285
d9a7a149-4338-407f-99f3-91e3b2603b1e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":16,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.277879
82190bd8-abc0-497b-8df3-6e81716e3c84	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":12,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.281408
5af88d1b-c954-4bf3-aeb1-4e54846ca829	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":26,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.299274
546d34ac-1619-40a3-b9eb-8af2bbf9e599	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":23,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.331972
756b74de-766a-4558-9041-fb80239f2284	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":20,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.335021
ed338cff-78c7-42f7-b454-3833834057e8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":20,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.337119
375ec917-29d0-4c13-9273-17c919520d1d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.340443
661fb67e-a96d-4402-a7df-74e0c0e2ee16	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":16,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:47:20.336122
f78a5312-ce06-4634-ae5b-cd1711cb71c0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":128,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.346415
2c073477-0139-4b61-90cf-a54ec46da1d1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":212,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.439154
89350490-0c73-41e8-860c-b9064192482f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":229,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.450743
a220e0ec-91f4-41c5-aa8e-b7e255e229ff	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":247,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.471254
fae5be2e-8a7b-444d-b7f3-0034e92f454b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":257,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.487799
0a7956df-b67c-44ec-b579-8fdd5b69d7ba	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":22,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.542644
65deffb9-c630-4df9-a858-301b4f6c14fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":20,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.546358
3e87f142-7be1-43a3-a611-71c8f3423fba	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":18,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.547096
86fd2892-a132-4aa5-995d-8504e19fcd1f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":18,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.550338
0858f8fb-c815-47cb-9bcc-d7918ec7b9f8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":21,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:51:16.547927
6a678fb3-0e20-4ee9-8dde-13ae5e285248	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":79,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.847731
2643794a-4118-40a1-97d2-5ff0da6d5743	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.889609
2fe6d078-6f59-4ebc-b0f9-4534dc569299	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":130,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.898899
93c168fe-f3d2-4810-baf9-4ee6a50b5b46	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":7,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.92713
e9d5650b-26df-4e93-866e-1cf3706c4836	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.938322
6fd1e1b2-5c7a-4034-b947-fd243571ef59	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.93567
faae0c84-04e0-4da7-9ca0-7a248ab63f91	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":131,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.902532
7f2008ac-32c0-452a-96a1-c59df56b4308	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":200,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:31.972869
4fc37dce-b24d-478d-9810-5de8cbd2b3db	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":240,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:32.014591
b93c228b-20dd-43a7-a740-a70c32a15606	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":152,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:32.037631
9ed00d6c-01ea-400c-be90-c87e2eaee929	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":11,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:39.332837
fcecdcbf-ac74-47c3-b96a-49f8543cca47	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":17,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:52:41.271057
6beff769-17a5-42de-bdfd-b343f7928b49	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":50,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:26.957478
2430df76-a6e1-40a5-8c2e-9f0bb8bdebfb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":199,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.104197
8f0b57e1-d204-4442-8645-c77824416a76	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.222327
4e6cece2-c514-44aa-94b9-479d5a1dc09b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":15,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.219649
c499127e-9b69-4797-8ef4-20d17ff5be4e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.243332
b0bd1ec5-b4a4-4f9f-936d-dd5d85c7ad46	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.244435
33acfe33-b40e-4d33-a247-8fd0aeaac35f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":38,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.253669
c138c55b-a004-45d0-aee2-590120af0096	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":412,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.331675
f788af10-617f-4c4b-bf89-71752c1d823c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":434,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.369498
e620fc30-deec-46a9-81dc-f401c32325ca	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":475,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.414525
774cc4de-f02b-4a3a-94dc-0c01f4abe8da	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":15,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.779753
7d84dc40-4914-45ea-83a1-1a0b8d8cc2b0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":15,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.853758
528a78e9-f2d0-4694-b231-097b49b5fcb5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":14,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.781565
9cde8b9c-691c-4dda-9f81-6836dbe6dee7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":63,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.89892
00b67e56-7905-4cc2-94af-194c9f4b5731	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":142,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.917341
0f71c419-40a6-40df-b7fb-d4ab56ea4ef2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":13,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.782658
980f8f7e-834a-4994-91e1-a18dfc50c452	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.841047
96ef57f0-ffff-4327-acc7-c1d8d10056b6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.854562
4201d064-e43f-47ef-bce8-aa054468de61	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.862068
cba0adb6-4ba8-4d24-ad3e-d477c1c1b63a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":139,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	200	\N	2026-05-08 00:54:27.910777
a97e5a5d-fe59-4967-a155-5034b9384fd1	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login","duration":246,"responseSize":392}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:47.686574
4ad9c198-0b04-4716-bdc0-b2a60467eca7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":282,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.100191
4a663b97-8bf4-44df-93fd-0387a23adab1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":528,"responseSize":1071}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.313637
d1473357-ad82-4c53-940a-121729ceb444	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":411,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.204276
0ac306f3-9563-45c2-828c-4389d6b2a9bc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":698,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.49948
b6f1b969-47a4-4ba4-8e6f-f76d125e3437	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.609461
403717dd-fcf8-41a7-beb1-980f705ea778	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":30,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.678604
2c5f1e03-8ddb-430c-998d-d33c59cfd4ed	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":21,"responseSize":566}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.675771
7699f750-c32f-4696-b2d0-c013acf7633a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":28,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.687039
17e648b0-e95d-4c41-b892-5c54b25102b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":34,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.688619
a9146b9c-4a7c-40dc-9ce1-e1752e932c78	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":1064,"responseSize":1258}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:00:48.889624
b4904ecd-c1fb-4ade-9d3d-278e28d0eadc	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":98,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:53.155809
4ee5c0fc-9eb4-4396-965b-8df252f30a41	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:53.8085
ab205c9c-3a97-469e-9def-b2e826b9ec3e	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:53.973719
08309135-1fe9-41c1-974a-17e906f969a2	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":5,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.12258
5ea48e16-e152-467b-b2a7-c5fb998ed771	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.260387
59ee7bea-7583-4b23-840b-f6f5717222cc	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.398166
6af2e2f6-6b53-4ed0-abf9-b0a39ef72445	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.534913
2d321d6c-54ca-4d5e-91e7-0867dce70fe7	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.671899
8e944d1f-c793-4bac-8149-28e08fb76221	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":210}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.8106
36d93847-4aa8-4864-aae3-f5f78fe33987	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:54.965092
e7784f71-b588-4783-a72f-d46864551b0b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:55.119995
fada3719-f376-43fb-913d-bc95c7cf1d14	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:55.955875
a2a17969-6689-45e4-8755-f76abe922e0a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.059151
ba48539f-108f-4b25-a9bf-828fcbb47444	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.143916
8d607e65-49c9-47be-a55a-51a211a51162	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.229685
3765033b-d49a-491b-9f22-b70f5987ee1c	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.323961
87f8e42d-3a46-4679-85f9-ae010db44b84	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":2,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.508747
c4da548c-cc14-41e8-adbe-1b432992ea62	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.596854
fe76a077-aac7-4048-9a5d-6ade0ee5827b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.68164
da24bae8-5050-4be3-bc93-7f63fc922951	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:56.794617
27bd2237-9754-425f-9455-dc90f52f4a1d	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":3,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.512535
1e8df4a9-429f-439b-a89d-b4a6679b129b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":4,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.595954
cddbbfd8-8f2c-4725-b50e-e37807831e01	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":4,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.692121
91bbca50-961a-4c09-8ba3-0b4e11323151	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":5,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.784971
7bd40475-70c9-47ac-8e82-e6c483c1fe8a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":3,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.872925
a4a6bc14-e202-4740-a27f-6050d6b97d7a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":4,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:57.962162
0df1363a-3c2e-42de-8686-c4c5a80b4961	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":3,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:58.054233
a8e6218f-1767-4fda-814d-aff89889174b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":4,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:58.143476
18de85dd-0fe4-4787-b15a-59809aeca994	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":4,"responseSize":196}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:58.238174
2123b97f-e7d9-4e54-8445-50d7427f302d	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.3589
c81ab3f8-8051-42a1-aa55-398ebcff3789	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.459636
f8cabd46-da31-488d-9cd6-4c5005156806	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.552396
4326cac8-d3dd-47f3-b538-0b13c1514697	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":2,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.442436
387a192c-5ddd-45b3-b419-f11e3f5c7f0a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.615911
2ae8c302-0732-47ef-ba58-e9f9910eb7e1	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.702686
42c41908-214e-4b05-9c95-085bbeaed0e9	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":3,"responseSize":205}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:06:59.796978
3765b69b-5edd-4527-a3ef-867bac7065c1	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"PATCH","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/vote","duration":4,"responseSize":246}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:00.4129
d35a9db1-f487-4383-9b97-9704dc83a9c6	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"PATCH","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/vote","duration":2,"responseSize":246}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:00.475502
bb6e21ba-a4e4-4c14-b92f-5da9e6b0119e	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"PATCH","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/vote","duration":3,"responseSize":246}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:00.553512
3998b98d-44ea-4b5f-bfea-92364368f32c	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"POST","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":7,"responseSize":262}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:05.461849
292e757f-6a6a-4728-a79e-b2302d50398b	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	SURVEYS	\N	{"method":"POST","path":"/api/surveys","duration":80,"responseSize":831}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:23.728915
8ac01f61-82b1-4011-aa8c-92fb61390416	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":1,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:29.275002
392fafdc-2ca2-4036-bf0e-a8de172d5cf6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":115,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:07:31.157174
00c44b2b-72a9-4112-92af-9bbc65794a33	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":226,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:09:59.143682
c91ca626-d287-4a27-a0b8-0bd1c3f3678b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/issues"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	500	Converting circular structure to JSON\n    --> starting at object with constructor 'Socket'\n    |     property 'parser' -> object with constructor 'HTTPParser'\n    --- property 'socket' closes the circle	2026-05-10 17:10:01.998763
6626cdab-f037-4938-869a-7211e636ba01	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":107,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:55.807118
0fe03c7e-1711-4007-85b8-fa0672534158	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":120,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:55.81418
f0074804-83df-4efe-bf18-3c0f6911a4ad	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":157,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:55.848189
3a43f443-63aa-4464-9164-5ab497031250	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":6,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:55.876638
80362bc6-087f-4d7d-8920-77669b917cef	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":158,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.03279
14907fb8-6933-410b-8f67-3d29c4c873e0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":35,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.400591
6b96baf0-afe4-42ec-8455-d1f160699ba3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":31,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.407191
453be279-cec0-4e6b-acb1-c2931cac8f0c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.447375
193b61d4-1e45-460b-9abc-0dcdb5477940	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":4,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.526568
6e585496-c4d2-4af7-b7c7-026e34866d96	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":38,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:56.407895
d0fe33e1-3083-4a5d-8c1b-c6214367dee4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":2,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.414094
9b3c7624-8919-4d7d-b03b-6d078799866a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":3,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.420643
0316045b-a7f6-454c-87c3-72e92a1616d4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":2,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.452536
4827b544-0da9-49e7-a0f4-bf23ecaa69b0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":4,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.667538
6d5afbf7-5fd1-4c86-8441-fe15252263b6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.79857
4f0a73f4-1914-4c9f-9844-0288554f628c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":13,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.577723
f69b003b-15fa-41c4-827f-acd06a2545cb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.669655
a72b45ff-8494-467f-ab6e-093f9e5fb85d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":4,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.811997
616d581a-a418-44a3-be41-aa6625dfbb15	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:13:58.665981
103cbcef-195c-45b9-b93c-80f8ef2c2e38	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":191,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.330857
3e64bb9d-8d8c-40cf-9c6e-a180e1ad95f0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":202,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.356392
8c678600-2095-4b5e-86a5-8eaf5bcd4f41	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":182,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.333199
f3f7b5c1-83b8-4c8e-8b89-0c40775f58a3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.505166
3682e8fd-7df7-47bf-b7b4-a6edcc4dd060	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":19,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.507686
36689d49-c293-41c1-8af3-df2caca0b7d8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.514284
6d4b4e92-073e-4806-a44a-63ea6f18f385	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":43,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.522372
c643e9b3-c70f-4eac-ae2e-c9240c683539	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.663087
e58ac479-05e2-4509-96e3-1cfdd2a916a3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":577,"responseSize":315}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.736717
224ce097-46af-4bf9-ba4a-7214f3f400c3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":597,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:21:44.762399
4652316b-f593-48a0-8f24-e42b930ec6af	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":119,"responseSize":352}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:22:10.633646
2c2403d6-de1a-4c64-adea-b738ad7e4f38	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":357,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:50.229182
216b8b36-cafe-47f1-a99e-fe5bc182606f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":482,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:50.340292
59c2be1e-d753-4c13-895f-f8ff915eb30f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":468,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:50.332596
ec3d7b37-d630-4969-a5ca-1379001b731e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":8,"responseSize":672}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:50.503632
431e0479-a5ae-423a-aac6-d3f721fa0cfe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":88,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.093322
6db2cae8-576e-44e6-83ba-f6178bed441a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.232016
307a8058-6678-4483-a5e6-d3d87ca2acdf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.232922
686d784d-9368-40fc-a750-aa8567748099	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":14,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.249986
caa7a6e4-ea4b-401c-a2e9-7697c594ebbe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.251797
d2dda009-0d0a-4e69-8278-5fefd23cb14c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":110,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:23:52.352194
b0392a8a-7676-445f-99b1-836a8ee0323a	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":119,"responseSize":320}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:24:27.958755
db177552-4c4e-4781-a55c-00d0e2dcb4d2	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":170,"responseSize":344}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:24:49.35033
4db090d2-26d0-4edc-8132-1089a76f87d5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":331,"responseSize":1362}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:46.933386
47867995-ccf0-4f53-93e9-a3f54179d0d9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":320,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:46.92383
8f39fd96-8014-429d-91fa-4ba8f926a655	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":14,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.041474
9bd00a3f-da06-4f0c-aa76-fbea09dd4a15	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.042806
7a9f3ba0-4468-44b4-99e8-26f7ceb6991f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":437,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.044803
a7ce5e8d-0b05-4d14-837d-5b961b880f46	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.087332
227a59b5-a180-4d18-b12d-cc9e5a21323f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.090514
dcce1124-1c51-49c7-a650-1665e3ae5311	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":540,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.146043
6db0570d-b45b-4661-82ea-7fbf16e867b5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":582,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.19176
5acc79ea-1b14-42b5-8662-77b689a904c7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":211,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:25:47.243713
9c037eb9-82d5-4f2a-ac89-48d2be49e937	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":229,"responseSize":322}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:26:32.896578
b4ac09f0-a105-4f1e-b611-606e15d43205	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":313,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:27:07.205853
be4e47d8-ebd7-488d-a81f-4bf807a654a4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":14,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:27:08.755698
5f128fe4-b21f-41d6-b7a6-ae5aa3c2c6a2	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":5,"responseSize":326}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:27:16.478213
c43b9ed8-41ce-43d8-b0f0-c5e959719c7c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":219,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:27:37.480338
79d7892c-4a6a-4ce0-bba5-4cd3c1a919db	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":16,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:27:38.449176
9345a16f-8f4e-4cc4-bd35-9f9835c1d3d8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":432,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:28:00.619157
a274e099-7848-4767-8833-314a5fcddfe1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":216,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:28:14.249423
53ee12cb-84fa-4569-8b21-7ed9dff76c47	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":191,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:06.843157
305bcf84-e162-4d6d-8275-feae5ccf8ea7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":183,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.397872
426969e0-46b8-4238-98a2-86336ee1d515	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":251,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.460352
112bb1a7-c784-47ba-be51-3e5154b50208	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":254,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.461978
365bc1eb-a1ca-49a9-8ca1-2744d49b715d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":278,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.489457
f396a417-66ba-4050-b992-9cfb2fa67e9d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":18,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.518525
76f6eb14-eb07-4a14-8940-a14110458cf4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.514524
d5082f94-dec1-4e19-97ec-e56aaabc575b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":18,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.522365
c1ac710e-8831-43b1-8429-ff7ec39c8faa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":18,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.523183
b195299d-7778-466b-aa6d-466d733ba51e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":39,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.546053
e82488b8-d78d-43f6-a56b-ad8ae28f5fdc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":345,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:24.562328
dc7c25a8-370a-4d2a-9b0e-a7d094cadafb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":188,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.721816
23adda40-e681-413f-80f0-a9acd4169e1d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":252,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.780163
b9b11a72-6e74-44c9-b9b4-ed77d7777397	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.854968
bb1efbae-1ab8-42d1-ab3a-67ab07f954bc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":10,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.86422
9de79757-ae1a-4f48-a790-40e1b45d19d8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.868002
b11fae29-8023-4a31-b6bf-93a0935fdba3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":392,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.9273
ea80d917-e188-4953-b1f4-c56b234f1a77	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.863102
af77483a-a65a-4771-9daa-f498b4ab1007	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":271,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.801076
11cc69b6-2278-4095-a6b8-698568a6890a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":405,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:36.936194
c235dd8a-8a1e-43f0-8e17-da8d363bdf2f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":159,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:37.019268
4321e923-dd2e-4700-958f-c16cd05cb328	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":7,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:40.355818
18c16414-cbfb-477f-93de-2b20463108c1	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:40.719572
c8166bf1-3638-48d7-899f-7fff6adae95f	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.390434
e9a55e1b-fe6d-499a-8dfc-e98fab4a0356	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.489636
49ea6174-8b45-4270-aded-b0767c63a491	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.571351
5554d6da-18e2-4a8e-bd74-cd5687f82bea	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.672815
2adac327-5e2e-4133-a431-ef46d5295fc3	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.742625
0087ed64-bfdf-4df1-966f-d740e8ad91b1	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.844757
f125ee0b-bf75-40bd-82e8-06587f8004be	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:41.947691
6fe3317f-d64c-4dcc-9f60-b1b3b2342066	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.041288
dba47678-885c-487d-8fa1-149367f7ca36	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.123058
1ebb434d-9ddf-4404-96ae-687263508fbc	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.221808
b119602f-5650-4781-b396-36c5ee826e32	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.305588
58aa9767-69ff-4a5f-a4c4-361aa9c3a2d8	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.393727
bb223868-bf55-4475-a4ac-bae805912de1	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.477246
64f1644b-8412-4133-971e-c3d0f201f200	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.562515
964f4b2e-f31f-4955-b390-bab21d6d35fa	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.653055
d56604a5-7b59-4e42-8daa-499ad8eddd7d	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.747151
5478d629-6d52-40fc-86ad-a83755f3bfa4	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.837648
4abcd707-a18b-4a21-9e12-3df0997e32ac	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:42.915228
ec63ba81-007b-448a-914b-5da831cb6fff	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":2,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.019748
ab0c2cb6-a960-4d4a-827e-edc9fb19b3e4	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.100765
e07faa5b-cecc-4246-887c-2ab116ea0772	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.201197
43b776bb-79e1-41ef-ae24-2e81b548402d	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.265799
e16d5f6a-d5ee-4976-a878-1886ef3d4677	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.371563
c3210bad-d78c-4486-bf08-4a95d198e30a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":5,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.467425
40a1ae79-6f5b-43ee-9eb6-c753dfb111ac	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.559713
c8eb396f-b07b-4da0-9ba2-689e3c4c369b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.647941
2e4041d6-93be-4dd0-9178-6c4b22de01d6	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.749236
f8ffd02d-56be-4e6f-a8a3-a5509a35e1d2	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.825221
273d9b1b-35fd-465f-8d87-4318d060be05	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":5,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:43.934433
630aa807-3851-4c63-8268-d3951ce4b72b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:44.015837
7825ae90-0469-463c-a2d2-d46762ad4d90	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:44.137835
3c3e0bbe-72ee-49cc-85a8-052fc8d0e221	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":276,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.630372
18ac60e2-2a43-40ca-a92d-648c9d45c7ce	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:44.308212
b2695338-324c-4161-8570-d07e1061cf4b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":129,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:34:50.026651
dfae5f6c-332b-468c-b956-6f4148d7b770	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":202,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.688395
a943c196-3edd-47fe-87bd-afbd3d99a8de	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.74778
1496db0d-5ba1-4475-ab33-5332aff815fa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":211,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.703119
f432d31f-5ea5-4dcc-a977-3d270e8951fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":5,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.802685
e1e9f469-0c4e-4fd1-ab82-335a39939211	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.803355
b6427601-ffe0-42db-9366-c80f19509322	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":331,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.823347
246a4555-f12a-479a-b8ff-531556235baf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":293,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.781665
2b6fc2fa-0bfd-485d-b327-2bee99a4b725	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":406,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.901323
2db9f381-5f68-40db-9573-09ac3fccc262	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":164,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.911357
82d8b12f-84ae-402b-a775-b5393a80ccdf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":181,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:03.926142
19731ed3-1868-43fe-abd6-cd33178b67f7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":337,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.646754
73001907-a82e-465f-bad4-b1e8c02d1e93	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":413,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.71962
02a0e98c-35b5-4714-b7ad-b489ad7f06b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":423,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.741794
6345e645-bad7-4cfe-bd5b-586cebead8d4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.778758
87e4f2b8-9b55-4887-bd5e-9ac6968c6742	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.79879
73320599-e32f-40c3-96c5-9d2df86e837c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.799738
59918f19-9ece-457e-9855-0cb26cca69f3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":15,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.803891
3f89311f-3e12-4893-9248-dd14ef159139	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":17,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.801326
8dd6e957-c17d-4b74-9efc-8dea44dcfc7a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":500,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.820578
4f767ac1-f996-44b4-a508-03a5ae5dc3cc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":524,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:35:41.849121
6681ad09-577c-40bf-809e-8d528506553d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":151,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.507682
1069e6f7-3d3b-4d7f-bbe4-09ac9c39a4c0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":242,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.594098
abcaf8a9-65b0-4b7e-8852-d99f341f0685	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":242,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.596692
a0d6ece3-cf0f-4d8d-8fda-2555f390c5bb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":278,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.63684
0e407dbe-333d-4bf1-bff6-d9de0ae222c7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.653289
db8b1b1e-5c30-4831-ae7f-33f20c285de0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":14,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.668193
125027f9-7613-48d3-bef4-8f43254022dc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":18,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.674822
2d2deb23-3c74-4e0f-914a-1ccace6298c3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":21,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.685461
895d87a8-8f6f-4e49-8ff1-4ac2cda535bf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":18,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:01.678966
091d1120-f8c9-4ee7-8b08-262a6053521e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":14,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:03.073549
4db39400-13ed-4187-9912-8eb09878b9e0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":6,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:06.023945
8bf7ebc4-49b7-42c3-8e4f-54282dea4f0f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":152,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:36:29.125602
c9ccfb9d-0899-48ed-abac-b9feca5d08f6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":111,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:39:31.063763
e9051a93-308c-4b2c-875a-754470b21382	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":124,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:39:31.089432
c5e3085d-588e-4492-a17a-b2cf04e2792c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":136,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:16.516942
d9fce6d6-9e4f-4985-b76b-fa811c5fd4fb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":135,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:16.526421
4ad9c0c7-1fb3-4de0-ba91-31a9391a2276	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":21,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.306209
ddfe112a-eb1d-4364-9d10-9aa5dc700f46	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":24,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.304589
6d0f3c21-3ca2-43d2-8b6e-610f405b354e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.511321
ab985866-9d9e-468c-8161-a7be72e2ed91	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":6,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.535158
33cf7252-6d1e-459d-9b95-842a5a1d0a06	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":253,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.545352
1508748e-6893-46c4-a878-b357c3489dcb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":229,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.519303
85e1d637-d3b5-444a-ae8a-4ec9f3654723	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.570281
b307b3f6-8265-4b8e-8ea8-9e9933ca4de2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.540518
2ce07ce0-cf88-41e3-8127-503f8da4a761	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":312,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.607018
2d8e4552-cf32-42f0-863c-69969a083247	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:23.572335
77f7c804-8ef6-4fb1-bbd3-fd2dbbe10409	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":3,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:26.344676
19c4a537-3946-4a61-ad06-f94d3c4453e8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":3,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:26.345753
49f9a3dd-6370-483d-bf7a-521f6d458a2b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":13,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.005103
b5993bbc-2555-44d9-97a9-5ca4293994fa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":10,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.006163
4753a3c6-7b6b-460a-9bce-d54883772374	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":14,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.00706
56cd478d-1e31-465a-95ec-4d164aff95e1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":10,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.00784
a3489ad9-0a16-4e48-b268-cf69283610bf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":19,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.018031
3d922dd6-0f13-4d2b-82a0-32e12225f14f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":10,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.06056
7528dabf-5779-41da-940c-0d189f3ffab1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":15,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.062647
08d76e59-85d9-48c6-a0be-a09f9ced581e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.064454
7dc77591-09f1-44d8-90e4-15b22fd7b20b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.061992
2d263806-c457-48c8-b84c-9cd342e06983	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:41:31.061296
0befe904-ce21-42d4-b71a-a0eafce4a4bb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":178,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:45:46.086283
925718e8-9511-4aa5-9814-cf7fca3d84d4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":3,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:45:46.910453
ada6dcb5-a84b-45ce-8b5e-a3459b749019	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":4,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:45:46.914114
a8c877b3-440a-4b44-9883-73445197b56f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":161,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.437325
12edd1be-6b35-44ea-a027-942dea2fc272	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":210,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.487253
c093a143-2c67-44ef-a74d-4f9164c99cc3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":198,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.471207
6557efc3-b9e3-4372-9232-d8b4ec94c9fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.552866
8a27932e-78c3-444b-b019-1b6c6cec732a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.554171
bbc934e7-cbb0-4858-88c9-df95715301c3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":11,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.5558
1ee106f6-30bb-4846-8f9b-82b16f733eaa	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.574283
b942233b-c0de-4fac-9dcf-2285ab2af572	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":291,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.571784
1e91e92f-88ca-4b75-94c5-2fa544426ba5	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":334,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.616836
7190387b-8fde-4e25-9982-111a38f7da94	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":174,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:46:40.721944
ad60351c-66b9-4618-9bd0-c7e954c89237	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":15,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.527168
855e25ee-1d86-43f5-ade6-d38ec95390bd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":162,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.676679
93e81dc7-7005-4e06-bf3a-fb262eee9c69	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":7,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.70585
586eb1f1-bdd9-45e9-aaf9-45c07f2b3737	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":93,"responseSize":2022}	::ffff:127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.795238
9eb04fbb-d1ff-437b-a6e5-b07b26646773	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":5,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.955707
7a09c579-c98b-42be-a7d1-9686b4c9e7bf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":4,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:38.957184
3bb6d443-aa18-4b2d-bef4-3b2d4b75fb7d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":6,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:39.188569
6ed16d36-e72f-494d-92b9-c8a3e8be628c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":16,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:47:39.195374
8b366aab-0f50-442a-951b-78b2cacae8d1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":175,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:48:41.702404
83f89c60-72eb-4fbc-8787-6ce15943b5db	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":217,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:48:41.738013
c019b222-1a99-41b5-ad81-775de63650b0	\N	CREATE	AUTH	\N	{"method":"POST","path":"/api/auth/login","duration":123,"responseSize":392}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.748413
c3d504d5-205c-4708-9d5e-e12b456b0107	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":17,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.798106
4135d9f1-7f2c-4b6e-8e3a-555818e907b1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":8,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.917046
8413d2ee-19d8-4714-bf38-2ed6ba9a5617	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":4,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.939805
b3fda94f-cad7-4294-984c-90b3787f0cb8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.948777
8ef8b650-3339-4446-81d9-ba6762229521	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":2,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:53.996348
333d8b4f-cb1c-4b4b-ac88-179ac1dfab09	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":236,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:54.019638
1f76017a-5131-4e99-add1-a5a82b965181	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":337,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:54.125342
c730c2d4-806e-4fbb-9c4f-89206ba0cf1c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":220,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:54.130872
1c28863d-6136-4645-ae6e-b65a3da89913	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":385,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:54.170038
699ded2f-1173-4503-beab-15366112acd8	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":399,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:54.190263
5285b45a-f268-4835-be74-73a045f9eab2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":3,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:55.504623
4b8da0a6-1a6c-406f-9941-b637b9fcbe1a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":8,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:50:55.506017
3353695c-aeca-4717-96d4-0f599fa8a120	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":115,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.283673
69a94bac-b685-408d-94e4-ee5d5c76095d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":82,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.24916
10847078-f176-46e1-a144-9be82d894962	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":7,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.344652
c2e07686-fa23-467c-955f-b98419157852	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":188,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.358555
fabac309-82a1-45d9-a118-32444e46a1a1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":10,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.395755
b1608bbb-ef9b-4500-bbc1-529ecff22e1a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.407926
12774c27-178a-40fb-b671-de67f33b872d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":305,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.477434
58a283c4-2278-46b0-ae15-f1985814e609	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":318,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.4923
2d7aa099-9e1e-4798-b6b5-89f273240875	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":174,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.50752
fb36b297-ed38-4af7-8ac5-974802ab5ad0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":205,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:16.531803
d81a7eb0-4283-42ad-a914-5e7eeaa2297d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":10,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 17:55:21.74165
585630d2-cf52-4d30-ada3-0b4ef0a66a83	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":91,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.18515
dc23acfa-7570-4c63-b869-99ababd85408	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":169,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.256159
10f430cf-0c9b-4d90-89f9-f6f41ddd8284	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":246,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.336035
1d185f5a-46f5-4846-bc04-33d7ad1566b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":269,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.366411
4d2edbb2-c75f-4b77-a055-a248c1ff4f4b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":287,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.389177
6e2b9dc8-cb55-49f4-bcf8-015f65526d30	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.436579
c5470f08-29fd-43ed-98c1-0fda54df4752	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.443644
ac24f29c-d5ce-4626-93d1-d92b4665ca38	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":17,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.444958
a20da8b4-0acc-4ada-9474-dbce27203cf4	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.449443
e91e235c-c0ce-4e29-811d-d3d94f49d2ba	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:17:17.454423
d49805cb-78e0-4151-a2a3-056697d14164	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":100,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:05.798735
65ca071a-2af2-4e26-8ab1-697a1ec1ad9e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":5,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:05.836035
b70c868b-823d-4543-b389-451ce6a03def	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":6,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:05.861156
5880fe31-1859-45aa-9afe-5308021c4b7d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":6,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:05.880247
d9aaaa65-d86d-419a-9af6-d3516b47addb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":125,"responseSize":1289}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.02159
ed29f9b3-3796-4322-98a1-763f1a7fc769	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.145349
59598731-ab75-4e55-9fb9-80e3a5517f3b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.159355
13cacedc-b7c7-4f68-b5f2-1ee49f5aa156	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":11,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.15042
a72c7bbe-66dc-434c-962f-2c9de6c8562c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.148475
a4aa688e-f4ee-41d1-910d-912ab955a593	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:18:06.163886
8ca341eb-3a5d-4a82-89a6-7d85483466c9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":190,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:25:28.998242
55b98c07-9b94-48ce-ac4e-caeeb0fc42dc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":216,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:25:29.035881
4c844af0-d62c-4346-bd82-d2a906436dbe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":231,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:25:29.043453
320dde9e-43e6-4425-8bc2-301a7e0e9a71	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":269,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:25:29.08326
845d8e74-ce64-4ea0-9f51-f5cd968ca5fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":90,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:40:42.19169
bac80d48-027a-4beb-ab9f-0697ad69c6e9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":89,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:40:42.183926
e68c773b-bb7b-4c07-b721-e61ad55d4063	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":102,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:40:42.199983
a4bedd51-0db5-42ca-bded-072c8bc7f9b9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":86,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:40:42.184881
169e4015-1a7f-44df-90a4-9adee26c40c8	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":76,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:06.006522
2a615b19-f30a-4c66-a551-38ebf0178579	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":8,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:07.676804
c9ba8510-d3c7-4581-b508-f89b9ad4adf9	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":8,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:13.919312
527dcaf7-4443-4bb5-b399-b2e4cc222204	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":340,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.094934
4e6f1b8b-d35e-4794-9d8c-ed6cde380951	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":8,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:14.933119
9972c013-911d-4204-9825-75656d6b2382	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":8,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:16.101122
0424e4af-41a2-4da0-a3b4-98d2d83c13ff	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":8,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:18.078402
588a60d4-4bcf-4332-b4ef-be5f3986787c	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":8,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:19.769816
ae886ae4-89b1-4941-bfca-ce699ba26c29	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":8,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:20.721427
f29a3341-d717-4018-8e5c-1395f850c352	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":8,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:21.37445
a437240f-a96b-43c1-a865-852f7bbf5e06	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":10,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:22.490754
17cbb560-9f95-4086-8c0a-83d63a4acff0	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":8,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 18:43:23.254929
6c4b2c97-fc7f-4d8c-9d70-5522b02b5c55	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":105,"responseSize":2022}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:04:41.860104
ad392709-e0e4-45a2-bc93-11e7ee877207	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":190,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:04:41.952013
42ed79cd-51c0-49ed-b532-ce40f4d5c250	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":175,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:04:41.942888
4b33439b-587b-4cb8-ba7f-249e9f10bddf	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":227,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:04:41.992862
14573847-9fa9-4b16-87e8-acd18515e2bc	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":58,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:06:43.912868
724ab8e9-7e95-47af-8622-0e93c41784db	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":6,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:06:46.313562
db853047-81fa-4bd4-873b-6f162ade7e8f	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/IN_REVIEW","duration":8,"responseSize":638}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:06:47.77883
a219341b-8c74-420a-b024-ef603242c728	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":6,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:06:48.791693
2957cfd6-d7eb-4685-9b5a-628434c428dd	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":7,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:06:49.92455
6ddcb2e2-9872-4732-9279-afbbf297e1b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":153,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:49.266723
b5c77efc-f7c9-45b9-bfc9-2283b90957b3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":253,"responseSize":2024}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:49.363418
8d5e4e2e-8f49-4602-889a-f897eef26c31	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":327,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:49.443144
2e18fc23-5c03-4b33-95c1-4f102b090e8f	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":337,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:49.455715
16636657-f5e0-45f2-a60b-3366069b5172	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":11,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:52.299385
a53ec091-715b-40d0-9a11-519748b2f028	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":6,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:53.283472
2c13513e-ec04-4f5d-b11f-b65af37ee718	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":334,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.083497
cd47b5b4-bd3f-489d-bf8c-2205475ff0fc	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/CLOSED","duration":7,"responseSize":635}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:54.418883
b1a44b3e-35b3-4dd9-a88d-19e3a80d9cf3	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":10,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:55.731574
3f7f7af6-425e-467a-b883-cdc8350b6bb7	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":9,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:56.57999
fa016cd9-2c43-401f-b59c-58437b378bfa	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/IN_REVIEW","duration":7,"responseSize":638}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:57.426366
aa63c7b4-baa2-48de-9a07-cf6f54cf405c	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/OPEN","duration":7,"responseSize":633}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:58.35349
b41e84ac-7080-4e26-ae4d-31dd5f147f75	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	ISSUES	e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	{"method":"PATCH","path":"/api/issues/e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa/status/RESOLVED","duration":7,"responseSize":637}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:07:59.0173
e65642da-17ae-44ff-a60b-534fdfd4496e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":165,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.020375
9854c013-e68d-427f-ac86-d497bd8e83e3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.091865
6e7bf71b-2bf5-4c5a-b2f8-4dc0e029d3c1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":208,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.060497
71081fe8-8a52-45fa-ae46-a67fef119344	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":20,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.095698
47456799-d640-4038-8f25-9299d5210c3a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":14,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.094069
4b8a939d-b6cb-4f91-bbed-251102374c17	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":11,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.092863
ce433ed8-1dd5-4564-9562-c331a7d23fea	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":189,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.040385
c89e3baa-7426-43c1-bae8-38e1c4c3adc3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":188,"responseSize":1072}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.038379
b57c6298-cdae-4895-b2a7-3c54428867fe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":305,"responseSize":1323}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.162145
3305de37-9fa7-45dd-a16c-5d93f1bb7183	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":98,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:31.182871
f5184d70-ffe0-4992-add6-1f863e1de7ee	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":114,"responseSize":1323}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:08:43.804381
9a2c96f2-a787-4a1a-ab2d-f282afb774ce	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/export/csv/surveys"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	500	Converting circular structure to JSON\n    --> starting at object with constructor 'Socket'\n    |     property 'parser' -> object with constructor 'HTTPParser'\n    --- property 'socket' closes the circle	2026-05-10 19:08:59.78208
69096948-1791-494c-98d1-0bbab7bffe86	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":378,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.129766
026ca717-e9a4-46d9-b8d7-0c993d554865	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":16,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.142659
8db3a4b1-4ae7-4b91-abaa-67e2f9d3d52d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":12,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.16372
47e687dd-303f-44bd-9412-95504317d69c	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.167201
ee5c1601-3a9c-4ad3-b405-602997dfbfcb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":369,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.12186
abd4da14-6553-4690-b88a-80068eedaeb7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":181,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.320027
aaadf6cf-e743-494d-878b-c18fac394c7e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":542,"responseSize":1323}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.298833
1a439893-cdbd-4a06-8ab7-e17db592a880	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":232,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:36.359782
2e4ab432-3ced-4edd-ab72-1cf33f99df0b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":7,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:41.694061
b6d2c7d1-5b6e-4175-b3fd-d94ea8a7cb30	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:41.811644
8a15bd34-039c-446f-9e53-d18681e8065e	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:41.940532
18d1f0d9-8bbd-4665-9d99-7d2c83b2f512	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":2,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.069133
36311c5f-9c69-4ab5-a794-93bb5e1ba733	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.221206
fed788da-e5e1-4ab8-98b2-2b42154a2569	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.343235
d8b75ed7-ba22-401b-85f0-23f526445c4a	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.448142
a3fcd223-1976-408e-8965-7e6c67e5b66f	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.597543
9ab49330-a1d9-4229-960f-6db765cb6a16	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:42.740517
191cf5d1-7116-4335-b6cc-0519daa09122	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":2,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.050555
bb150681-9574-439c-bb2d-f608b22b89d0	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.131904
8925aa90-63dd-40c5-9163-019e43f4209b	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.227514
3e8ddb6d-59f0-4624-a0f6-07f60d483df3	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.30705
2614f9cb-ba04-44a1-b43b-b79b8230d16e	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":4,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.379701
6df73a69-f64e-4493-a725-11c8ec971800	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.479374
c6ddf211-3352-470b-b159-b15feb5f95a3	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.541065
093be1fe-a479-4f59-be64-eb7c04a7e21d	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":3,"responseSize":211}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:16:43.630083
0ea0c3c5-09ae-4b9a-9a51-1835abb2ceea	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":210,"responseSize":1157}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.542764
96561f3e-6b48-4d66-b463-5b3f2ea15d99	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":336,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.690202
154f05fa-6662-4573-b283-a15fbf097e5b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":233,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.568124
9dd8a31e-c02a-4875-ad91-ff58c3284f55	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":344,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.683221
842877d2-2020-4aa7-b4a6-f63a54a71a8a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":25,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.76647
9af1c88f-693c-441b-9f3a-4d95b2b361a6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":20,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.769328
74f78a99-3b3f-42b6-bd03-a3d5e66097e2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":21,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.767567
300d4f84-93ae-411e-8273-ef467c4d494d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":446,"responseSize":1408}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.792122
84a9e8aa-2979-426d-abdb-2e81b64044b6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":48,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.802715
5b8a98dc-6388-494f-9396-03da0ffb4ffb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":47,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:19:59.804403
1c929e4c-32cd-4e5a-98e4-831602aba3e0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":186,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.427084
5200127a-12a7-40df-ae3b-0c17cfd85c77	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":133,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.421829
8b3b21a6-4e0d-453e-8fb5-f134dd8f96ad	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":297,"responseSize":1157}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.512629
81ecdfaa-f7b6-4e76-8e37-cfb40600f5da	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.742838
1df29f1b-8d6a-498c-8a0d-b793587a9298	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":13,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.768505
f1da6e0b-f86c-4a9b-9e91-dd2952915520	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":20,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.769632
e76bc5da-7304-45f4-8006-18e53de8dd23	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":19,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.771092
ec926049-a15a-40f2-a99e-8673c162718b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":499,"responseSize":1408}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.814314
a3b56b4b-df23-4403-9581-c6a405765489	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":506,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.818351
6f81857b-06a6-4129-8fd9-5b0d3129016a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":98,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:51.857301
1bdfb30a-1345-4b66-b8c8-5cc05305b137	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"PATCH","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/vote","duration":7,"responseSize":267}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:52.646433
2d31360c-30da-4b0b-8544-51ffc7789a02	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"PATCH","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/vote","duration":3,"responseSize":253}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:54.161012
22788a1a-511c-4b04-b030-00582008f227	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"PATCH","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/vote","duration":4,"responseSize":302}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:56.033689
41ae6387-bfac-40f2-9ba5-3515147c1ec4	7a1f15c5-d607-4020-9217-e56c0b657c11	UPDATE	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"PATCH","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/vote","duration":5,"responseSize":261}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-10 19:20:56.759052
28345488-8ae4-49cc-80be-aecf2311d5ab	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":285,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.665243
5175a3c1-c0c0-463b-a57e-07537ad59969	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":272,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.661932
4a9d1d56-105d-4fd1-99b6-7fb3b92ed856	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":277,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.650948
00fc6e1d-3850-43b9-a20d-0d8c5549e8b2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.715042
22ffb4a4-ed73-429b-989c-7761907c1e2b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":19,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.712801
702108b5-97fc-4e87-9730-1343d8bd903b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":357,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.743846
69683a76-20cf-4375-9bb6-3c82c33fd40b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":16,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.717008
47192ea4-4274-4e21-b724-070229e4ca6b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":439,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.79177
be4cdcf7-199c-4acf-9e92-7336143f81b7	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":122,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.826674
132c142b-e553-4ea2-b50f-1552e7f3f1c9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":119,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:42:48.850496
c4e11620-7fe4-435c-9a1e-33573cafaf11	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":109,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:43:42.389708
9cbc3036-8240-4a3d-a386-49a24054f45a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":136,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:43:42.423874
66c7f772-36da-48a3-af6f-aad2ee448f5a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":157,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:43:42.448785
16ec49e4-85d0-49d9-a761-b82deed912d1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":241,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:43:42.526112
85f96ce4-47de-4b6c-93ba-b65ab923ec95	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":201,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:34.981324
469eab85-cbd0-4f53-ac7c-d63bae04e8c2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":215,"responseSize":2026}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.00536
2e5a5520-36e9-4371-9a34-86becca53151	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":196,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:34.98524
99079797-6b44-4763-bc45-08ec0e70a472	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":284,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.071777
107febf7-85e6-48a7-8e27-3c2d448f4452	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":16,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.127659
7b3e05e8-292f-4d61-9480-021cb2de7db1	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":9,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.128473
e8f7b292-e8e9-44f3-864d-87b7d58c583a	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":12,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.129161
17c0a0fb-25ca-48a5-963a-6c2f377e524e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":36,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.131704
67592cfb-61d0-4183-82f7-85aa39e2dd4b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":17,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.131039
a9b56d76-56d4-403b-9868-98f4e68b77e2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":353,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:35.14531
235716f6-7bcd-42c2-a6cd-f1b6c7c3e684	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":166,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:56.702981
b48f190f-e4f9-41a7-af85-835870c4fe76	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":15,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:45:57.792736
c30c2ca6-588d-48ef-969c-6f3ac6898f22	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":185,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:46:08.836897
ab3f0a63-8899-4834-b90a-5fa9dbf43e1e	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":152,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:46:23.473314
5626b919-de2f-463d-a9da-ef7281081be3	7a1f15c5-d607-4020-9217-e56c0b657c11	CREATE	ISSUES	\N	{"method":"POST","path":"/api/issues","duration":80,"responseSize":326}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 00:47:05.533616
fb84198e-93b4-420b-a645-e2e4ff098689	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":108,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.037443
6b5cded2-cea3-457c-bc3d-c1bb5847e2fc	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":15,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.162028
dbacea3a-2ab4-4905-8afd-a9bc4133f954	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":254,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.187864
6acc21f5-e520-4142-b205-7c9d78f3da06	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":270,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.202405
3154cdad-d20a-4018-ae16-9391fc9d19f2	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":269,"responseSize":2359}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.203581
e6a5dcb0-90e1-4d4d-a07e-9c1ec3a55475	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":8,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.226986
4fdcb794-be78-488e-be52-d2dcacbb54ce	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.227666
7bd5b68f-ad67-44bd-bdfb-35b2a3f914f9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.232622
26c91df4-5141-4e1d-bfa7-6689acaf6563	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":312,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.249605
6fa35ba6-d275-4614-b8ce-e7b62e884a14	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":144,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:06:40.294578
4865d75a-2ca7-45d6-bc71-b87bb59d6791	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":61,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.034989
935c3f85-752c-487f-b046-54b537aa09a3	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":137,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.114086
6193e749-6556-45e3-a114-6c5dc392100b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":135,"responseSize":2359}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.117973
6dd56477-cb78-4371-a9c2-3b221797786d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":150,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.135192
869a5704-cdd0-4eb2-a507-02f99fa61fba	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":165,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.144154
b4ff9a6b-7a1f-450e-8494-321c3a2a4c35	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":6,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.180045
35a4709f-9241-4461-b747-64983be54022	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":2,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.187878
7e9409d6-7684-461f-ad46-fd51755349fe	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":4,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.201733
8adc68a6-8fa6-489e-a87c-d8cbbf069630	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":7,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.205543
eed101e6-552c-498b-92d0-0e0cf11523d0	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":3,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:08:28.211077
a84c09ac-33bf-42a7-bc6f-eb6974a799d6	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	\N	{"method":"GET","path":"/api/proposals","duration":181,"responseSize":1314}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.51935
cbb6d8e6-280b-47e0-9a76-acc08a539948	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	SURVEYS	\N	{"method":"GET","path":"/api/surveys","duration":263,"responseSize":288}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.603516
5b3bbd36-c3dd-4260-8b6b-726ae47a3c94	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	BUDGETS	\N	{"method":"GET","path":"/api/budgets","duration":358,"responseSize":368}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.701983
1be9881f-26b3-412b-9fe8-177385f6f8f9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	{"method":"GET","path":"/api/proposals/7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7/comments","duration":22,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.765911
054b4fe4-95a0-4b07-8caa-fd74389602bd	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	33ce90d9-133d-4599-8167-c13007b6b39c	{"method":"GET","path":"/api/proposals/33ce90d9-133d-4599-8167-c13007b6b39c/comments","duration":19,"responseSize":1131}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.768555
68fb7ecb-190a-4460-81a9-e481caa44abb	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	e3cbaa66-c3c6-4daa-bda1-9a3670761532	{"method":"GET","path":"/api/proposals/e3cbaa66-c3c6-4daa-bda1-9a3670761532/comments","duration":5,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.790211
1d8db9fc-16c7-4a70-a1ca-717162ec24c9	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	8ad5804d-25cd-47ea-ba22-10a08af5b709	{"method":"GET","path":"/api/proposals/8ad5804d-25cd-47ea-ba22-10a08af5b709/comments","duration":25,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.776928
b49c4dab-7f05-49be-9251-e64864c0508b	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	PROPOSALS	a0b0b89e-c3d1-4473-a303-77914dec4e93	{"method":"GET","path":"/api/proposals/a0b0b89e-c3d1-4473-a303-77914dec4e93/comments","duration":28,"responseSize":2}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.776413
589d03d3-d517-4a1e-a010-6e4d94e2a545	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	ISSUES	\N	{"method":"GET","path":"/api/issues","duration":604,"responseSize":2359}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:09:59.968918
7dc4b1fe-aa66-4836-b10c-28574ecb180d	7a1f15c5-d607-4020-9217-e56c0b657c11	READ	REPORTS	\N	{"method":"GET","path":"/api/reports/summary","duration":643,"responseSize":1565}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	200	\N	2026-05-11 01:10:00.030366
\.


--
-- Data for Name: budget_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budget_items (id, "budgetId", title, description, "estimatedCost", "voteCount", "isActive") FROM stdin;
\.


--
-- Data for Name: budget_votes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budget_votes (id, "budgetId", "itemId", "userId", "createdAt") FROM stdin;
\.


--
-- Data for Name: budgets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budgets (id, title, description, status, "totalAmount", "allocatedAmount", "createdBy", "participantsCount", "startDate", "endDate", "allowMultipleVotes", "createdAt", "updatedAt") FROM stdin;
dfcde9ea-4c53-4af5-b83b-791e4c04eac6	fds	fdsfsdfdsfdsfds	DRAFT	-351.00	0.00	7a1f15c5-d607-4020-9217-e56c0b657c11	0	\N	\N	t	2026-05-08 00:35:24.067662	2026-05-08 00:35:24.067662
\.


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.issues (id, title, description, category, status, latitude, longitude, address, "createdBy", "createdAt", "updatedAt") FROM stdin;
b47c1c78-b3b6-4491-9ccb-d0e766ecbddd	dsdsa	dsadas	dsadsa	OPEN	0.0000000	0.0000000	dasd	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-08 00:35:08.497262	2026-05-08 00:35:08.497262
ba107aae-d53d-4390-b253-52bcfd33868c	DFSSDFFDSFSD	SDFSDFSDFSDFSFDSFDS	DFSFDSDFSDSF	OPEN	-33.4319786	-70.6253891	SDFDFSSDFSDFFDSDF	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-10 17:22:10.615188	2026-05-10 17:22:10.615188
525aeab0-d827-416e-b72d-37619e702079	TITULO	NECESIDAD TERRITORIAL XD	CATEGORIA	OPEN	0.0000000	0.0000000	DIRECCION	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-10 17:24:27.924164	2026-05-10 17:24:27.924164
16c78a63-e1ac-4055-9f4f-c9c174828512	TITULO	NECESIDAD TERRITORIAL XD\n\n	CATEGORIA	OPEN	-33.4513521	-70.6281984	DIRECCION	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-10 17:24:49.33623	2026-05-10 17:24:49.33623
c6030567-2be7-446f-8cc2-42e5339a5dad	FDG	GFDDFG	FGDGFFGD	OPEN	-33.3974823	-70.7951863	FGGFDFDGFGDFGDFDG	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-10 17:27:16.473123	2026-05-10 17:27:16.473123
e9fcc783-9eb1-4e2a-b3fa-7ec40ab00eaa	FDSFDSSDF	FSDFSDFDSFDSFD	DFSDFS	RESOLVED	-35.1226970	-71.6778390	DSF	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-10 17:26:32.883035	2026-05-10 19:07:59.012759
e2db38ee-5727-40ce-9487-4c20e64d7b70	DFSSDFFDSFSD	cap	DFSFDSDFSDSF	OPEN	-34.9680600	-71.2247001	DIRECCION	7a1f15c5-d607-4020-9217-e56c0b657c11	2026-05-11 00:47:05.519602	2026-05-11 00:47:05.519602
\.


--
-- Data for Name: proposal_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proposal_comments (id, "proposalId", "userId", content, status, "createdAt", "updatedAt") FROM stdin;
19ebe355-c179-4c20-9151-1bd70f34c194	33ce90d9-133d-4599-8167-c13007b6b39c	7a1f15c5-d607-4020-9217-e56c0b657c11	DSADSAD	VISIBLE	2026-05-08 00:34:28.10582	2026-05-08 00:34:28.10582
77b663ba-914b-4b79-9104-44642e1ad782	33ce90d9-133d-4599-8167-c13007b6b39c	7a1f15c5-d607-4020-9217-e56c0b657c11	gfdgfdf	VISIBLE	2026-05-10 17:07:05.456233	2026-05-10 17:07:05.456233
\.


--
-- Data for Name: proposals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.proposals (id, title, description, votes, category, "createdAt", "votedBy") FROM stdin;
e3cbaa66-c3c6-4daa-bda1-9a3670761532	hgfhgfhfhgfhghffghhfgghf	hgfhfhfghgffgdgfddfgfdgfdgfdfgdgfd	0	Medio Ambiente	2026-05-07 23:55:19.625928	[]
7c5f920d-2b12-4d03-8ce7-3d78be6ea1a7	SDAAAAAADSASDASADSDASDADSA	SDAASDDASSADSADSDASADDSASADSDASDA	72	Infraestructura	2026-05-08 00:47:20.241099	[],7a1f15c5-d607-4020-9217-e56c0b657c11
a0b0b89e-c3d1-4473-a303-77914dec4e93	XDDDDDDDDDDD	DDDDSADSDSDSADSASDASDASADSDASDASDA	10	Medio Ambiente	2026-05-08 00:45:25.138244	[],7a1f15c5-d607-4020-9217-e56c0b657c11
33ce90d9-133d-4599-8167-c13007b6b39c	FSDFDSSDFFDSDSFFDSFSDFSDSDFFDSFDSFDS	FSDFSDFDSSDFFDSDFSSFDFSDFDSFDSFDSFDSFDSFDSFDSSDFFDDFSFDSFDSDSFFDSDF	4	Cultura	2026-05-08 00:34:18.515915	[],7a1f15c5-d607-4020-9217-e56c0b657c11
8ad5804d-25cd-47ea-ba22-10a08af5b709	DFSDFSFDFDSsddsadsasddsadsadsa	DSADSADSASDDSASDADSAdasdsadasdsadsa	7	Otro	2026-05-08 00:14:42.605879	[],7a1f15c5-d607-4020-9217-e56c0b657c11
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questions (id, "surveyId", text, type, "order", "isRequired", options, "conditionalLogic", "isConditional") FROM stdin;
223fc53a-2ed2-4b91-8103-39f89fcb5ef6	bdcbaf7b-27a3-4b00-9c6f-d9f807ff776a	jhgjhg	MULTIPLE_CHOICE	0	t	\N	\N	f
\.


--
-- Data for Name: survey_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.survey_responses (id, "surveyId", "questionId", "userId", response, "createdAt") FROM stdin;
\.


--
-- Data for Name: surveys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.surveys (id, title, description, status, "createdBy", "responseCount", "startDate", "endDate", "createdAt", "updatedAt") FROM stdin;
bdcbaf7b-27a3-4b00-9c6f-d9f807ff776a	jjhhjghjgghj	jhggh	DRAFT	7a1f15c5-d607-4020-9217-e56c0b657c11	0	\N	\N	2026-05-10 17:07:23.703254	2026-05-10 17:07:23.703254
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, "firstName", "lastName", email, password, role, "isActive", "createdAt", "updatedAt") FROM stdin;
7a1f15c5-d607-4020-9217-e56c0b657c11	Admin	User	admin@example.com	$2b$10$fYgPrXoY89McUdCsuzzVDOYrYRFY/YiGz9on3UufymWuArLPB0lYi	ADMIN	t	2026-05-07 23:24:21.373243	2026-05-07 23:24:21.373243
\.


--
-- Name: questions PK_08a6d4b0f49ff300bf3a0ca60ac; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT "PK_08a6d4b0f49ff300bf3a0ca60ac" PRIMARY KEY (id);


--
-- Name: surveys PK_1b5e3d4aaeb2321ffa98498c971; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT "PK_1b5e3d4aaeb2321ffa98498c971" PRIMARY KEY (id);


--
-- Name: audit_logs PK_1bb179d048bbc581caa3b013439; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "PK_1bb179d048bbc581caa3b013439" PRIMARY KEY (id);


--
-- Name: survey_responses PK_349995c51959d139d8e485a58ea; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT "PK_349995c51959d139d8e485a58ea" PRIMARY KEY (id);


--
-- Name: proposal_comments PK_3dad96e1019f8d511df6b116cc7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_comments
    ADD CONSTRAINT "PK_3dad96e1019f8d511df6b116cc7" PRIMARY KEY (id);


--
-- Name: budgets PK_9c8a51748f82387644b773da482; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT "PK_9c8a51748f82387644b773da482" PRIMARY KEY (id);


--
-- Name: issues PK_9d8ecbbeff46229c700f0449257; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT "PK_9d8ecbbeff46229c700f0449257" PRIMARY KEY (id);


--
-- Name: budget_items PK_9eb705f406c83a1167ef575cd7f; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_items
    ADD CONSTRAINT "PK_9eb705f406c83a1167ef575cd7f" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: budget_votes PK_d1806eda753201c7a01066a23ad; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_votes
    ADD CONSTRAINT "PK_d1806eda753201c7a01066a23ad" PRIMARY KEY (id);


--
-- Name: proposals PK_db524c8db8e126a38a2f16d8cac; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT "PK_db524c8db8e126a38a2f16d8cac" PRIMARY KEY (id);


--
-- Name: budget_votes UQ_4e5e061ca381836253b6b51c7a7; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_votes
    ADD CONSTRAINT "UQ_4e5e061ca381836253b6b51c7a7" UNIQUE ("budgetId", "itemId", "userId");


--
-- Name: IDX_01993ae76b293d3b866cc3a125; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_01993ae76b293d3b866cc3a125" ON public.audit_logs USING btree ("entityType");


--
-- Name: IDX_0e287721421e8c5bda5df7554e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_0e287721421e8c5bda5df7554e" ON public.surveys USING btree ("createdBy");


--
-- Name: IDX_1160fb85bb3cb492ac954b491a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_1160fb85bb3cb492ac954b491a" ON public.budget_items USING btree ("budgetId");


--
-- Name: IDX_1edcec695ce3307fd5ae10a425; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_1edcec695ce3307fd5ae10a425" ON public.budget_votes USING btree ("budgetId", "userId");


--
-- Name: IDX_25456193c41e36fb15a8762243; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_25456193c41e36fb15a8762243" ON public.surveys USING btree ("createdAt");


--
-- Name: IDX_320d90aefea87f75695826bee9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_320d90aefea87f75695826bee9" ON public.issues USING btree (category);


--
-- Name: IDX_4aa358cc467984a3ed3d84480a; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_4aa358cc467984a3ed3d84480a" ON public.survey_responses USING btree ("surveyId", "questionId", "userId");


--
-- Name: IDX_585cf990e152374b53e2f602a4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_585cf990e152374b53e2f602a4" ON public.budgets USING btree ("createdBy");


--
-- Name: IDX_7715e9e280a0669fe87b94b275; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_7715e9e280a0669fe87b94b275" ON public.proposal_comments USING btree ("proposalId", "createdAt");


--
-- Name: IDX_8516c74dacfffb4f125eb7d408; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_8516c74dacfffb4f125eb7d408" ON public.surveys USING btree (status);


--
-- Name: IDX_89ca33753af44ac86e4164968e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_89ca33753af44ac86e4164968e" ON public.budgets USING btree (status);


--
-- Name: IDX_8ecc195da60806a8391d54ea6e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_8ecc195da60806a8391d54ea6e" ON public.survey_responses USING btree ("questionId");


--
-- Name: IDX_8eee23e5ccebd4025ecaccda1b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_8eee23e5ccebd4025ecaccda1b" ON public.questions USING btree ("surveyId");


--
-- Name: IDX_97672ac88f789774dd47f7c8be; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_97672ac88f789774dd47f7c8be" ON public.users USING btree (email);


--
-- Name: IDX_b7fd6df20da19c630741ea9045; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_b7fd6df20da19c630741ea9045" ON public.issues USING btree (status);


--
-- Name: IDX_c10a3c7798c9351b83bb0b7554; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c10a3c7798c9351b83bb0b7554" ON public.budgets USING btree ("createdAt");


--
-- Name: IDX_c69efb19bf127c97e6740ad530; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_c69efb19bf127c97e6740ad530" ON public.audit_logs USING btree ("createdAt");


--
-- Name: IDX_cee5459245f652b75eb2759b4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cee5459245f652b75eb2759b4c" ON public.audit_logs USING btree (action);


--
-- Name: IDX_cfa83f61e4d27a87fcae1e025a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cfa83f61e4d27a87fcae1e025a" ON public.audit_logs USING btree ("userId");


--
-- Name: IDX_de966c4e90eaa10b99609b81a4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_de966c4e90eaa10b99609b81a4" ON public.issues USING btree ("createdAt");


--
-- Name: surveys FK_0e287721421e8c5bda5df7554ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT "FK_0e287721421e8c5bda5df7554ef" FOREIGN KEY ("createdBy") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: budget_items FK_1160fb85bb3cb492ac954b491a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_items
    ADD CONSTRAINT "FK_1160fb85bb3cb492ac954b491a9" FOREIGN KEY ("budgetId") REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- Name: proposal_comments FK_33949131a17ab964b54d3880432; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_comments
    ADD CONSTRAINT "FK_33949131a17ab964b54d3880432" FOREIGN KEY ("proposalId") REFERENCES public.proposals(id) ON DELETE CASCADE;


--
-- Name: budgets FK_585cf990e152374b53e2f602a41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT "FK_585cf990e152374b53e2f602a41" FOREIGN KEY ("createdBy") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: budget_votes FK_5f9b155d8470ba2883930d47d0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_votes
    ADD CONSTRAINT "FK_5f9b155d8470ba2883930d47d0d" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: issues FK_85505b36f65efb50c51827f5174; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT "FK_85505b36f65efb50c51827f5174" FOREIGN KEY ("createdBy") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: survey_responses FK_8ecc195da60806a8391d54ea6e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT "FK_8ecc195da60806a8391d54ea6e5" FOREIGN KEY ("questionId") REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: questions FK_8eee23e5ccebd4025ecaccda1b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT "FK_8eee23e5ccebd4025ecaccda1b2" FOREIGN KEY ("surveyId") REFERENCES public.surveys(id) ON DELETE CASCADE;


--
-- Name: proposal_comments FK_c43561833eb995de6570e76bc73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proposal_comments
    ADD CONSTRAINT "FK_c43561833eb995de6570e76bc73" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: survey_responses FK_c7a0ff24e1b4cf879e0199bcf93; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT "FK_c7a0ff24e1b4cf879e0199bcf93" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: survey_responses FK_ce01227f38da9eedae96f1f4c06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT "FK_ce01227f38da9eedae96f1f4c06" FOREIGN KEY ("surveyId") REFERENCES public.surveys(id) ON DELETE CASCADE;


--
-- Name: audit_logs FK_cfa83f61e4d27a87fcae1e025ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "FK_cfa83f61e4d27a87fcae1e025ab" FOREIGN KEY ("userId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: budget_votes FK_d7f60d0f71b41f07c46ecb4912d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_votes
    ADD CONSTRAINT "FK_d7f60d0f71b41f07c46ecb4912d" FOREIGN KEY ("itemId") REFERENCES public.budget_items(id) ON DELETE CASCADE;


--
-- Name: budget_votes FK_e4a9f5b2bec405c43381787141e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budget_votes
    ADD CONSTRAINT "FK_e4a9f5b2bec405c43381787141e" FOREIGN KEY ("budgetId") REFERENCES public.budgets(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 4zzmaiKJh7syrJ95Zv229Rr4LEpSiiMa1x4ErbVzweXqmq35uIos7ofGHjiY07X

